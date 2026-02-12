<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { Shield, Upload, Loader2, CheckCircle2, AlertTriangle, Clock, Image as ImageIcon } from 'lucide-vue-next'
import { toast } from 'vue-sonner'
import { authStore } from '../lib/authStore'

const imageUrl = ref('')
const loading = ref(false)
const result = ref(null)
const recentHistory = ref([])
const isDragging = ref(false)

const tasks = [
  { id: 'porn_moderation', label: 'Pornography', active: true },
  { id: 'suggestive_nudity_moderation', label: 'Suggestive', active: true },
  { id: 'gore_moderation', label: 'Gore', active: true },
  { id: 'drug_moderation', label: 'Drugs', active: true },
  { id: 'weapon_moderation', label: 'Weapons', active: true },
]

const selectedTasks = ref(tasks.filter(t => t.active).map(t => t.id))

const toggleTask = (taskId) => {
  if (selectedTasks.value.includes(taskId)) {
    selectedTasks.value = selectedTasks.value.filter(id => id !== taskId)
  } else {
    selectedTasks.value.push(taskId)
  }
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

const fetchRecentHistory = async () => {
  try {
    const { data, error } = await supabase
      .from('moderation_history')
      .select('*')
      .eq('user_id', authStore.session?.user.id)
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
    
    const { data: { user } } = await supabase.auth.getUser()
    
    // Fetch user's API key (get the first one, preferably the default)
    const { data: apiKeys, error: apiKeyError } = await supabase
      .from('api_keys')
      .select('api_key')
      .eq('user_id', user.id)
      .eq('is_revoked', false)
      .limit(1)
      .single()
    
    if (apiKeyError || !apiKeys) {
      toast.error('No API key found. Please create an API key first.')
      loading.value = false
      return
    }
    
    // Call the Supabase Edge Function with API key
    const { data, error } = await supabase.functions.invoke('moderate-image', {
      headers: {
        'x-api-key': apiKeys.api_key
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

const handleDrop = (e) => {
  e.preventDefault()
  isDragging.value = false
  
  const url = e.dataTransfer.getData('text/plain')
  if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
    imageUrl.value = url
  } else {
    toast.error('Please drop a valid image URL')
  }
}

const handleDragOver = (e) => {
  e.preventDefault()
  isDragging.value = true
}

const handleDragLeave = () => {
  isDragging.value = false
}

const loadHistoryItem = (item) => {
  imageUrl.value = item.image_url
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
})
</script>

<template>
  <div class="moderator-page fade-in">
    <div class="moderator-header">
      <div class="title-with-icon">
        <Shield class="icon-accent" :size="28" />
        <h2 class="gradient-text">Image Moderator</h2>
      </div>
      <p class="text-secondary">Enterprise-grade AI content filtering</p>
    </div>

    <div class="moderator-grid">
      <!-- Left Column: Input & Controls -->
      <div class="moderator-card glass">
        <div class="drop-zone" 
          :class="{ 'dragging': isDragging }"
          @drop="handleDrop"
          @dragover="handleDragOver"
          @dragleave="handleDragLeave"
        >
          <Upload :size="48" class="drop-icon" />
          <h3>Drop Image URL Here</h3>
          <p>or paste below</p>
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

        <button @click="handleModerate" :disabled="loading || !imageUrl" class="btn-primary btn-large">
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
            <div v-for="(val, key) in result" :key="key">
              <div v-if="key.includes('_moderation') && typeof val === 'object'" class="sub-task-result">
                <span class="sub-task-label">{{ key.replace('_moderation', '').toUpperCase() }}</span>
                <span class="sub-task-status" :class="{ 'ko': val[key.replace('_moderation', '_content')] }">
                  {{ val[key.replace('_moderation', '_content')] ? 'REJECTED' : 'PASSED' }}
                </span>
              </div>
            </div>
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
                <span class="history-decision" :class="item.final_decision === 'OK' ? 'ok' : 'ko'">
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

.result-header.KO {
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

.sub-task-status.ko {
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
