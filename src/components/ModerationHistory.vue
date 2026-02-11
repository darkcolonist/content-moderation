<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import { 
  History, 
  ShieldCheck, 
  ShieldAlert, 
  Clock, 
  Image as ImageIcon, 
  ExternalLink,
  Search,
  Filter
} from 'lucide-vue-next'

const props = defineProps({
  userId: {
    type: String,
    default: null
  },
  isAdminView: {
    type: Boolean,
    default: false
  }
})

const history = ref([])
const loading = ref(true)
const searchQuery = ref('')
const filterStatus = ref('all')

const fetchHistory = async () => {
  loading.value = true
  try {
    let query = supabase
      .from('moderation_history')
      .select('*, profiles(email)')
      .order('created_at', { ascending: false })

    if (props.userId && !props.isAdminView) {
      query = query.eq('user_id', props.userId)
    }

    const { data, error } = await query

    if (error) throw error
    history.value = data || []
  } catch (err) {
    console.error('Error fetching history:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchHistory()
})

const filteredHistory = ref([])

watch([history, searchQuery, filterStatus], () => {
  let filtered = [...history.value]

  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    filtered = filtered.filter(item => 
      item.media_id?.toLowerCase().includes(q) || 
      item.image_url?.toLowerCase().includes(q) ||
      item.profiles?.email?.toLowerCase().includes(q)
    )
  }

  if (filterStatus.value !== 'all') {
    filtered = filtered.filter(item => item.final_decision === filterStatus.value)
  }

  filteredHistory.value = filtered
}, { immediate: true })

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleString()
}

const getConfidenceColor = (score) => {
  if (score > 0.9) return 'text-success'
  if (score > 0.7) return 'text-warning'
  return 'text-danger'
}
</script>

<template>
  <div class="history-container glass fade-in">
    <div class="history-header">
      <div class="title-with-icon">
        <History class="icon-accent" :size="24" />
        <h3 class="gradient-text">{{ isAdminView ? 'Global Moderation History' : 'Your Moderation History' }}</h3>
      </div>
      
      <div class="history-controls">
        <div class="search-box">
          <Search :size="16" />
          <input v-model="searchQuery" type="text" placeholder="Search by ID or URL..." />
        </div>
        
        <div class="filter-box">
          <Filter :size="16" />
          <select v-model="filterStatus">
            <option value="all">All Decisions</option>
            <option value="OK">OK Only</option>
            <option value="KO">KO Only</option>
          </select>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Loading records...</p>
    </div>

    <div v-else-if="filteredHistory.length === 0" class="empty-state">
      <Clock :size="48" />
      <p>No moderation records found.</p>
    </div>

    <div v-else class="table-container">
      <table class="history-table">
        <thead>
          <tr>
            <th v-if="isAdminView">User</th>
            <th>Image</th>
            <th>Decision</th>
            <th>Confidence</th>
            <th>Timestamp</th>
            <th>Tasks</th>
            <th>Details</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in filteredHistory" :key="item.id">
            <td v-if="isAdminView" class="user-cell">
              <span class="u-email">{{ item.profiles?.email || 'Unknown' }}</span>
            </td>
            <td class="image-cell">
              <div class="img-preview-container">
                <img :src="item.image_url" :alt="item.media_id" class="img-preview" />
                <a :href="item.image_url" target="_blank" class="external-link">
                  <ExternalLink :size="12" />
                </a>
              </div>
            </td>
            <td>
              <span class="status-pill" :class="item.final_decision === 'OK' ? 'success' : 'danger'">
                <ShieldCheck v-if="item.final_decision === 'OK'" :size="14" />
                <ShieldAlert v-else :size="14" />
                {{ item.final_decision }}
              </span>
            </td>
            <td>
              <span :class="getConfidenceColor(item.confidence_score)">
                {{ (item.confidence_score * 100).toFixed(1) }}%
              </span>
            </td>
            <td>
              <span class="timestamp">{{ formatDate(item.created_at) }}</span>
            </td>
            <td>
              <div class="tasks-list">
                <span v-for="task in item.task_call.split(',')" :key="task" class="task-tag">
                  {{ task.replace('_moderation', '') }}
                </span>
              </div>
            </td>
            <td>
              <button class="btn-icon small" title="View Raw JSON" @click="console.log(item.raw_response)">
                <ImageIcon :size="14" />
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>
.history-container {
  padding: 24px;
  width: 100%;
}

.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 24px;
}

.history-controls {
  display: flex;
  gap: 12px;
}

.search-box, .filter-box {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 4px 12px;
}

.search-box input, .filter-box select {
  background: transparent;
  border: none;
  color: white;
  font-size: 0.85rem;
  outline: none;
}

.history-table {
  width: 100%;
  border-collapse: collapse;
}

.history-table th {
  text-align: left;
  padding: 12px;
  font-size: 0.75rem;
  text-transform: uppercase;
  color: var(--text-secondary);
  border-bottom: 2px solid var(--border-color);
}

.history-table td {
  padding: 12px;
  border-bottom: 1px solid var(--border-color);
  font-size: 0.85rem;
}

.img-preview-container {
  position: relative;
  width: 40px;
  height: 40px;
}

.img-preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
}

.external-link {
  position: absolute;
  top: -4px;
  right: -4px;
  background: var(--primary-color);
  color: white;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s;
}

.img-preview-container:hover .external-link {
  opacity: 1;
}

.task-tag {
  display: inline-block;
  font-size: 0.65rem;
  padding: 2px 6px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 4px;
  margin-right: 4px;
  margin-bottom: 4px;
  color: var(--text-secondary);
}

.timestamp {
  font-size: 0.75rem;
  color: var(--text-secondary);
}

.text-success { color: #10b981; }
.text-warning { color: #f59e0b; }
.text-danger { color: #ef4444; }

.btn-icon.small {
  width: 28px;
  height: 28px;
}

.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px;
  color: var(--text-secondary);
  gap: 16px;
}

.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid rgba(255, 255, 255, 0.1);
  border-top-color: var(--primary-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@media (max-width: 1024px) {
  .history-table th:nth-child(5),
  .history-table td:nth-child(5),
  .history-table th:nth-child(6),
  .history-table td:nth-child(6) {
    display: none;
  }
}
</style>
