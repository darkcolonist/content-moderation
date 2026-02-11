<script setup>
import { ref } from 'vue'
import { supabase } from '../lib/supabase'
import { Shield, ImageIcon as ImageIconIcon, AlertTriangle, CheckCircle2, Loader2, Send } from 'lucide-vue-next'
import { toast } from 'vue-sonner'

const imageUrl = ref('')
const loading = ref(false)
const result = ref(null)

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

const handleModerate = async () => {
  if (!imageUrl.value) {
    toast.error('Please provide an image URL')
    return
  }

  loading.value = true
  result.value = null

  try {
    const { data: { user } } = await supabase.auth.getUser()
    
    // Call the Supabase Edge Function
    const { data, error } = await supabase.functions.invoke('moderate-image', {
      body: { 
        imageUrl: imageUrl.value, 
        tasks: selectedTasks.value.join(','),
        userId: user.id
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
</script>

<template>
  <div class="moderator-card glass fade-in">
    <div class="card-header">
      <div class="title-with-icon">
        <Shield class="icon-accent" :size="24" />
        <h3 class="gradient-text">Image Moderator</h3>
      </div>
      <p class="text-secondary">Enterprise-grade AI content filtering powered by PicPurify</p>
    </div>

    <div class="card-body">
      <div class="input-container">
        <label>Image URL</label>
        <div class="input-with-button">
          <div class="url-input-wrapper">
            <ImageIconIcon :size="18" class="input-icon" />
            <input 
              v-model="imageUrl" 
              type="url" 
              placeholder="https://example.com/image.jpg"
              :disabled="loading"
            />
          </div>
          <button @click="handleModerate" :disabled="loading || !imageUrl" class="btn-primary">
            <Loader2 v-if="loading" class="animate-spin" :size="18" />
            <Send v-else :size="18" />
            <span>{{ loading ? 'Analyzing...' : 'Analyze' }}</span>
          </button>
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
  </div>
</template>

<style scoped>
.moderator-card {
  padding: 32px;
  height: 100%;
}

.card-header {
  margin-bottom: 24px;
}

.input-container {
  margin-bottom: 24px;
}

label {
  display: block;
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-secondary);
  margin-bottom: 8px;
  font-weight: 600;
}

.input-with-button {
  display: flex;
  gap: 12px;
}

.url-input-wrapper {
  position: relative;
  flex: 1;
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
  background: var(--surface-light);
}

.tasks-selection {
  margin-bottom: 24px;
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

.result-display {
  margin-top: 32px;
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
  text-transform: uppercase;
  opacity: 0.8;
}

.decision-value {
  font-size: 1.25rem;
  font-weight: 800;
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

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}
</style>
