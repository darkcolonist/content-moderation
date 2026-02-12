<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import { Shield, Upload, Loader2, CheckCircle2, AlertTriangle, Clock, Image as ImageIcon, KeyRound } from 'lucide-vue-next'
import { toast } from 'vue-sonner'
import { authStore } from '../lib/authStore'

const imageUrl = ref('')
const loading = ref(false)
const result = ref(null)
const recentHistory = ref([])
const isDragging = ref(false)
const fileInput = ref(null)
const uploadLoading = ref(false)
const activeApiKey = ref(null)
const isInitializingKey = ref(true)
const isValidUrl = ref(false)

const validateCurrentUrl = (url) => {
  if (!url) return false
  try {
    const parsed = new URL(url)
    return ['http:', 'https:'].includes(parsed.protocol)
  } catch (e) {
    return false
  }
}

watch(imageUrl, (newUrl) => {
  isValidUrl.value = validateCurrentUrl(newUrl)
}, { immediate: true })

const tasks = [
  { id: 'porn_moderation', label: 'Pornography', active: true },
  { id: 'suggestive_nudity_moderation', label: 'Suggestive', active: true },
  { id: 'gore_moderation', label: 'Gore', active: true },
  { id: 'drug_moderation', label: 'Drugs', active: true },
  { id: 'weapon_moderation', label: 'Weapons', active: true },
]

const selectedTasks = ref([])

const toggleTask = (taskId) => {
  selectedTasks.value = [taskId]
}

const resizeImage = (file, targetSizeKB = 300) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.readAsDataURL(file)
    reader.onload = (event) => {
      const img = new Image()
      img.src = event.target.result
      img.onload = () => {
        const canvas = document.createElement('canvas')
        let width = img.width
        let height = img.height

        // Calculate aspect ratio
        const maxDimension = 2048
        if (width > maxDimension || height > maxDimension) {
          if (width > height) {
            height = Math.round((height * maxDimension) / width)
            width = maxDimension
          } else {
            width = Math.round((width * maxDimension) / height)
            height = maxDimension
          }
        }

        canvas.width = width
        canvas.height = height
        const ctx = canvas.getContext('2d')
        ctx.drawImage(img, 0, 0, width, height)

        // Adjust quality to hit target size
        let quality = 0.8
        let dataUrl = canvas.toDataURL('image/jpeg', quality)
        
        // Iterative compression if needed (simplified)
        if (dataUrl.length > targetSizeKB * 1024 * 1.33) { // 1.33 for base64 overhead
          quality = 0.6
          dataUrl = canvas.toDataURL('image/jpeg', quality)
        }

        // Convert dataURL back to Blob
        const arr = dataUrl.split(',')
        const mime = arr[0].match(/:(.*?);/)[1]
        const bstr = atob(arr[1])
        let n = bstr.length
        const u8arr = new Uint8Array(n)
        while (n--) {
          u8arr[n] = bstr.charCodeAt(n)
        }
        resolve(new Blob([u8arr], { type: mime }))
      }
      img.onerror = (err) => reject(err)
    }
    reader.onerror = (err) => reject(err)
  })
}

const validateImageSize = (url) => {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => {
      if (img.width > 4096 || img.height > 4096) {
        reject(new Error(`Image dimensions (${img.width}x${img.height}) exceed maximum allowed size of 4096x4096 pixels`))
      } else {
        resolve({ width: img.width, height: img.height })
      }
    }
    img.onerror = () => {
      reject(new Error('Failed to load image. Please check the URL.'))
    }
    img.src = url
  })
}

const fetchApiKey = async () => {
  isInitializingKey.value = true
  try {
    let userId = authStore.session?.user?.id
    
    if (!userId) {
      const { data: { user } } = await supabase.auth.getUser()
      userId = user?.id
    }

    if (!userId) {
      isInitializingKey.value = false
      return
    }

    const { data: apiKeys, error } = await supabase
      .from('api_keys')
      .select('api_key')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(1)
    
    if (error) throw error
    if (apiKeys && apiKeys.length > 0) {
      activeApiKey.value = apiKeys[0].api_key
    }
  } catch (err) {
    console.error('Error fetching API key:', err)
  } finally {
    isInitializingKey.value = false
  }
}

watch(() => authStore.session, async (newSession) => {
  if (newSession?.user?.id) {
    await fetchApiKey()
  }
}, { immediate: true })

const fetchRecentHistory = async () => {
  try {
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

    const { data, error } = await supabase
      .from('moderation_history')
      .select('*')
      .eq('user_id', authStore.session?.user.id)
      .gte('created_at', thirtyDaysAgo.toISOString())
      .order('created_at', { ascending: false })
      .limit(5)

    if (error) throw error
    recentHistory.value = data || []
  } catch (err) {
    console.error('Error fetching recent history:', err)
  }
}

const handleModerate = async () => {
  if (!imageUrl.value) {
    toast.error('Please provide an image URL')
    return
  }

  loading.value = true
  result.value = null

  try {
    // Validate image size first
    await validateImageSize(imageUrl.value)
    
    if (!activeApiKey.value) {
      // Try one last time to fetch it
      await fetchApiKey()
      if (!activeApiKey.value) {
        toast.error('No active API key found. Please create an API key first.')
        loading.value = false
        return
      }
    }
    
    // Call the Supabase Edge Function with API key
    const { data, error } = await supabase.functions.invoke('moderate-image', {
      headers: {
        'x-api-key': activeApiKey.value
      },
      body: { 
        imageUrl: imageUrl.value, 
        tasks: selectedTasks.value.join(',')
      }
    })

    if (error) throw error

    result.value = data
    if (data.status === 'success') {
      if (data.final_decision === 'OK') {
        toast.success('Image is clean!')
      } else {
        toast.warning('Image flagged!')
      }
      // Refresh recent history
      await fetchRecentHistory()
    } else {
      toast.error(data.error?.errorMsg || 'Moderation failed')
    }
  } catch (err) {
    console.error('Moderation error:', err)
    toast.error(err.message || 'Failed to moderate image')
  } finally {
    loading.value = false
  }
}

const uploadFile = async (file) => {
  if (!file) return
  
  // Basic pre-validation
  if (!file.type.startsWith('image/')) {
    toast.error('Only image files are allowed')
    return
  }

  uploadLoading.value = true
  try {
    // Resize and compress image before upload
    const processedBlob = await resizeImage(file, 300)
    
    const fileExt = file.name.split('.').pop() || 'jpg'
    const fileName = `${authStore.session.user.id}/${Date.now()}.${fileExt}`
    const filePath = `${fileName}`

    const { data, error: uploadError } = await supabase.storage
      .from('moderated-images')
      .upload(filePath, processedBlob, {
        contentType: 'image/jpeg'
      })

    if (uploadError) throw uploadError

    const { data: { publicUrl } } = supabase.storage
      .from('moderated-images')
      .getPublicUrl(filePath)

    imageUrl.value = publicUrl
    toast.success(`Image processed (${(processedBlob.size / 1024).toFixed(0)}KB) and uploaded`)
  } catch (err) {
    console.error('Upload error:', err)
    toast.error('Failed to process or upload image')
  } finally {
    uploadLoading.value = false
  }
}

const handleDrop = (e) => {
  e.preventDefault()
  isDragging.value = false
  
  const files = e.dataTransfer.files
  if (files && files.length > 0) {
    uploadFile(files[0])
    return
  }

  const url = e.dataTransfer.getData('text/plain')
  if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
    imageUrl.value = url
  } else {
    toast.error('Please drop a valid image file or URL')
  }
}

const handleDragOver = (e) => {
  e.preventDefault()
  isDragging.value = true
}

const handleDragLeave = () => {
  isDragging.value = false
}

const handleFileSelect = (e) => {
  const files = e.target.files
  if (files && files.length > 0) {
    uploadFile(files[0])
  }
}

const triggerFileInput = () => {
  fileInput.value.click()
}

const loadHistoryItem = (item) => {
  imageUrl.value = item.image_url
  isValidUrl.value = validateCurrentUrl(item.image_url)
  result.value = {
    final_decision: item.final_decision,
    confidence_score_decision: item.confidence_score,
    ...item.raw_response
  }
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleString()
}

onMounted(() => {
  fetchRecentHistory()
  fetchApiKey()
})
</script>

<template>
  <div class="moderator-page fade-in">
    <div class="moderator-header">
      <div class="title-with-icon">
        <Shield class="icon-accent" :size="28" />
        <h2 class="gradient-text">Image Moderator</h2>
      </div>
      <div class="header-subtitle-row">
        <p class="text-secondary">Enterprise-grade AI content filtering</p>
        
        <div v-if="isInitializingKey" class="active-key-badge glass">
          <Loader2 :size="14" class="animate-spin" />
          <span>Checking API Key...</span>
        </div>
        
        <div v-else-if="activeApiKey" class="active-key-badge glass success">
          <KeyRound :size="14" />
          <span>Using Key: <code>{{ activeApiKey.substring(0, 10) }}••••</code></span>
        </div>

        <router-link v-else to="/api-keys" class="active-key-badge glass warning">
          <AlertTriangle :size="14" />
          <span>No active API key found. Create one here →</span>
        </router-link>
      </div>
    </div>

    <div class="moderator-grid">
      <!-- Left Column: Input & Controls -->
      <div class="moderator-card glass">
        <div class="drop-zone" 
          :class="{ 'dragging': isDragging, 'uploading': uploadLoading, 'has-preview': imageUrl }"
          @drop="handleDrop"
          @dragover="handleDragOver"
          @dragleave="handleDragLeave"
          @click="triggerFileInput"
        >
          <input 
            type="file" 
            ref="fileInput" 
            class="hidden-file-input" 
            @change="handleFileSelect" 
            accept="image/*"
          />
          <template v-if="uploadLoading">
            <Loader2 :size="48" class="drop-icon animate-spin" />
            <h3>Uploading Image...</h3>
          </template>
          <template v-else-if="imageUrl">
            <img :src="imageUrl" class="preview-image" alt="Preview" />
            <div class="preview-overlay">
              <Upload :size="24" />
              <span>Change Image</span>
            </div>
          </template>
          <template v-else>
            <Upload :size="48" class="drop-icon" />
            <h3>Drop Image or Click to Upload</h3>
            <p>supports JPEG, PNG, WEBP (Max 5MB)</p>
          </template>
        </div>

        <div class="url-input-section">
          <label>Image URL</label>
          <div class="url-input-wrapper">
            <ImageIcon :size="18" class="input-icon" />
            <input 
              v-model="imageUrl" 
              type="url" 
              placeholder="https://example.com/image.jpg"
              :disabled="loading"
            />
          </div>
        </div>

        <div class="tasks-selection">
          <label>Moderation Tasks</label>
          <div class="tasks-grid">
            <button 
              v-for="task in tasks" 
              :key="task.id"
              class="task-toggle"
              :class="{ active: selectedTasks.includes(task.id) }"
              @click="toggleTask(task.id)"
            >
              {{ task.label }}
            </button>
          </div>
        </div>

        <button @click="handleModerate" :disabled="loading || !isValidUrl || selectedTasks.length === 0" class="btn-primary btn-large">
          <Loader2 v-if="loading" class="animate-spin" :size="20" />
          <Shield v-else :size="20" />
          <span>{{ loading ? 'Analyzing...' : 'Moderate Image' }}</span>
        </button>

        <!-- Result Display -->
        <div v-if="result" class="result-display reveal-in">
          <div class="result-header" :class="result.final_decision">
            <CheckCircle2 v-if="result.final_decision === 'OK'" :size="32" />
            <AlertTriangle v-else :size="32" />
            <div class="decision-info">
              <span class="decision-label">Final Decision</span>
              <span class="decision-value">{{ result.final_decision === 'OK' ? 'CLEAN' : 'FLAGGED' }}</span>
            </div>
            <div class="score-info">
              <span class="decision-label">Confidence</span>
              <span class="decision-value">{{ (result.confidence_score_decision * 100).toFixed(1) }}%</span>
            </div>
          </div>

          <div class="detailed-results">
            <template v-for="(val, key) in result" :key="key">
              <div v-if="key.includes('_moderation') && typeof val === 'object'" class="sub-task-result">
                <span class="sub-task-label">{{ key.replace('_moderation', '').toUpperCase() }}</span>
                <span class="sub-task-status" :class="{ 'flagged': val[key.replace('_moderation', '_content')] }">
                  {{ val[key.replace('_moderation', '_content')] ? 'REJECTED' : 'PASSED' }}
                </span>
              </div>
            </template>
          </div>
        </div>
      </div>

      <!-- Right Column: Recent History -->
      <div class="history-sidebar glass">
        <div class="sidebar-header">
          <Clock :size="20" />
          <h3>Recent Moderations</h3>
        </div>

        <div v-if="recentHistory.length === 0" class="empty-history">
          <p>No recent moderations</p>
        </div>

        <div v-else class="history-list">
          <div 
            v-for="item in recentHistory" 
            :key="item.id"
            class="history-item"
            @click="loadHistoryItem(item)"
          >
            <div class="history-image">
              <img :src="item.image_url" :alt="item.media_id" />
              <div class="history-overlay">
                <span class="history-decision" :class="item.final_decision === 'OK' ? 'ok' : 'flagged'">
                  {{ item.final_decision }}
                </span>
              </div>
            </div>
            <div class="history-meta">
              <span class="history-time">{{ formatDate(item.created_at) }}</span>
              <span class="history-confidence">{{ (item.confidence_score * 100).toFixed(0) }}%</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.moderator-page {
  padding: 24px;
  width: 100%;
  max-width: 1400px;
  margin: 0 auto;
}

.moderator-header {
  margin-bottom: 32px;
}

.header-subtitle-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 8px;
}

.active-key-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border-radius: 10px;
  font-size: 0.75rem;
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
  transition: all 0.2s;
  text-decoration: none;
}

.active-key-badge.success {
  border-color: rgba(16, 185, 129, 0.3);
  background: rgba(16, 185, 129, 0.05);
  color: #10b981;
}

.active-key-badge.warning {
  border-color: rgba(245, 158, 11, 0.3);
  background: rgba(245, 158, 11, 0.05);
  color: #f59e0b;
}

.active-key-badge.warning:hover {
  background: rgba(245, 158, 11, 0.1);
  border-color: #f59e0b;
}

.active-key-badge code {
  color: var(--primary-color);
  font-family: monospace;
}

.moderator-header h2 {
  font-size: 2rem;
  margin-bottom: 8px;
}

.moderator-grid {
  display: grid;
  grid-template-columns: 1fr 350px;
  gap: 24px;
}

@media (max-width: 1024px) {
  .moderator-grid {
    grid-template-columns: 1fr;
  }
}

.moderator-card {
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.drop-zone {
  border: 2px dashed var(--border-color);
  border-radius: 16px;
  padding: 48px 24px;
  text-align: center;
  transition: all 0.3s;
  cursor: pointer;
  background: var(--surface-hover);
}

.drop-zone.dragging {
  border-color: var(--primary-color);
  background: rgba(99, 102, 241, 0.1);
}

.drop-icon {
  color: var(--text-secondary);
  margin-bottom: 16px;
}

.drop-zone h3 {
  font-size: 1.25rem;
  margin-bottom: 8px;
  color: var(--text-primary);
}

.drop-zone p {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.preview-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: 12px;
  max-height: 250px;
}

.preview-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  opacity: 0;
  transition: opacity 0.2s;
  border-radius: 14px;
}

.drop-zone:hover .preview-overlay {
  opacity: 1;
}

.drop-zone.has-preview {
  padding: 12px;
  height: 280px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.url-input-section label {
  display: block;
  margin-bottom: 8px;
  color: var(--text-secondary);
  font-size: 0.9rem;
  font-weight: 500;
}

.url-input-wrapper {
  position: relative;
}

.input-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-secondary);
}

.url-input-wrapper input {
  width: 100%;
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 12px 12px 12px 42px;
  color: white;
  transition: all 0.2s;
}

.url-input-wrapper input:focus {
  border-color: var(--primary-color);
  outline: none;
}

.tasks-selection label {
  display: block;
  margin-bottom: 12px;
  color: var(--text-secondary);
  font-size: 0.9rem;
  font-weight: 500;
}

.tasks-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.task-toggle {
  padding: 8px 16px;
  border-radius: 99px;
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  color: var(--text-secondary);
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s;
}

.task-toggle.active {
  background: var(--primary-color);
  border-color: var(--primary-color);
  color: white;
  box-shadow: 0 4px 12px var(--primary-glow);
}

.btn-large {
  width: 100%;
  padding: 16px;
  font-size: 1.1rem;
}

.hidden-file-input {
  display: none;
}

.drop-zone.uploading {
  cursor: wait;
  opacity: 0.7;
}

.result-display {
  margin-top: 8px;
  background: rgba(255, 255, 255, 0.02);
  border-radius: 16px;
  border: 1px solid var(--border-color);
  overflow: hidden;
}

.result-header {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
}

.result-header.OK {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
}

.result-header.FLAGGED {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.decision-info, .score-info {
  display: flex;
  flex-direction: column;
}

.decision-label {
  font-size: 0.7rem;
  opacity: 0.7;
  text-transform: uppercase;
}

.decision-value {
  font-size: 1.25rem;
  font-weight: 700;
}

.detailed-results {
  padding: 16px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 12px;
}

.sub-task-result {
  background: var(--surface-hover);
  padding: 12px;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.sub-task-label {
  font-size: 0.6rem;
  color: var(--text-secondary);
}

.sub-task-status {
  font-weight: 700;
  font-size: 0.85rem;
  color: #10b981;
}

.sub-task-status.flagged {
  color: #ef4444;
}

/* History Sidebar */
.history-sidebar {
  padding: 24px;
  max-height: calc(100vh - 200px);
  overflow-y: auto;
  position: sticky;
  top: 24px;
}

.sidebar-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  color: var(--text-primary);
}

.sidebar-header h3 {
  font-size: 1.1rem;
  font-weight: 600;
}

.empty-history {
  text-align: center;
  padding: 40px 20px;
  color: var(--text-secondary);
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.history-item {
  cursor: pointer;
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.2s;
  border: 1px solid var(--border-color);
}

.history-item:hover {
  border-color: var(--primary-color);
  transform: translateY(-2px);
}

.history-image {
  position: relative;
  width: 100%;
  height: 160px;
  overflow: hidden;
}

.history-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.history-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
  display: flex;
  align-items: flex-end;
  padding: 12px;
}

.history-decision {
  font-size: 0.75rem;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 6px;
}

.history-decision.ok {
  background: rgba(16, 185, 129, 0.2);
  color: #10b981;
}

.history-decision.ko {
  background: rgba(239, 68, 68, 0.2);
  color: #ef4444;
}

.history-meta {
  padding: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--surface-hover);
}

.history-time {
  font-size: 0.7rem;
  color: var(--text-secondary);
}

.history-confidence {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--primary-color);
}

.reveal-in {
  animation: revealIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes revealIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
