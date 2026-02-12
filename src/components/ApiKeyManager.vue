<script setup>
import { ref, onMounted } from 'vue'
import { supabase, supabaseUrl } from '../lib/supabase'
import { 
  KeyRound, 
  Plus, 
  Trash2, 
  Copy, 
  Check, 
  Loader2, 
  ShieldAlert,
  Calendar,
  MousePointerClick,
  User
} from 'lucide-vue-next'
import { toast } from 'vue-sonner'
import { authStore } from '../lib/authStore'

const props = defineProps({
  isAdminView: {
    type: Boolean,
    default: false
  }
})

const apiKeys = ref([])
const loading = ref(true)
const creating = ref(false)
const newKeyName = ref('')
const copiedId = ref(null)

const fetchApiKeys = async () => {
  loading.value = true
  try {
    let query = supabase
      .from('api_keys')
      .select('*, profiles(email)')
      .order('created_at', { ascending: false })

    // If not admin, RLS will handle it, but we'll be explicit
    if (!props.isAdminView) {
      query = query.eq('user_id', authStore.session?.user.id)
    }

    const { data, error } = await query
    if (error) throw error
    apiKeys.value = data || []
  } catch (err) {
    toast.error('Failed to fetch API keys: ' + err.message)
  } finally {
    loading.value = false
  }
}

const handleCreateKey = async () => {
  if (!newKeyName.value.trim()) {
    toast.error('Please enter a name for the API key')
    return
  }

  if (apiKeys.value.length >= 5) {
    toast.error('Maximum limit of 5 API keys reached. Please revoke an existing key first.')
    return
  }

  creating.value = true
  try {
    // Generate a simple random key prefixed with sk_
    const randomPart = Array.from(crypto.getRandomValues(new Uint8Array(24)))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('')
    const newApiKey = `sk_live_${randomPart}`

    const { error } = await supabase
      .from('api_keys')
      .insert({
        user_id: authStore.session.user.id,
        api_key: newApiKey,
        name: newKeyName.value.trim()
      })

    if (error) throw error

    toast.success('API key created successfully')
    newKeyName.value = ''
    await fetchApiKeys()
  } catch (err) {
    toast.error('Failed to create API key: ' + err.message)
  } finally {
    creating.value = false
  }
}

const handleRevokeKey = async (keyId) => {
  if (!confirm('Are you sure you want to revoke this API key? This action cannot be undone.')) {
    return
  }

  try {
    const { error } = await supabase
      .from('api_keys')
      .delete()
      .eq('id', keyId)

    if (error) throw error

    toast.success('API key revoked')
    await fetchApiKeys()
  } catch (err) {
    toast.error('Failed to revoke API key: ' + err.message)
  }
}

const copyToClipboard = (text, id) => {
  navigator.clipboard.writeText(text)
  copiedId.value = id
  toast.success('API key copied to clipboard')
  setTimeout(() => {
    copiedId.value = null
  }, 2000)
}

onMounted(() => {
  fetchApiKeys()
})
</script>

<template>
  <div class="api-keys-container fade-in">
    <div class="dashboard-card glass">
      <div class="card-header">
        <div class="header-flex">
          <div class="title-with-icon">
            <KeyRound class="icon-accent" :size="24" />
            <h3 class="gradient-text">{{ isAdminView ? 'Global API Keys' : 'My API Keys' }}</h3>
          </div>
          <p class="text-secondary">
            {{ isAdminView ? 'Manage API keys for all users' : 'Create and manage your access tokens for the moderation API' }}
          </p>
        </div>
      </div>

      <!-- Create Key Section (Only for Users or Admin testing own keys) -->
      <div v-if="!isAdminView" class="create-key-section">
        <div class="input-group">
          <div class="label-flex">
            <label class="input-label">Key Name (e.g., "Production Web App")</label>
            <span class="key-count-label" :class="{ 'at-limit': apiKeys.length >= 5 }">
              {{ apiKeys.length }}/5 keys
            </span>
          </div>
          <div class="input-row">
            <div class="input-wrapper">
              <KeyRound :size="18" class="input-icon" />
              <input 
                v-model="newKeyName" 
                type="text" 
                placeholder="Enter a descriptive name..."
                class="input-field"
                @keyup.enter="handleCreateKey"
                :disabled="creating || apiKeys.length >= 5"
              />
            </div>
            <button 
              @click="handleCreateKey" 
              class="btn-primary create-btn" 
              :disabled="creating || !newKeyName.trim() || apiKeys.length >= 5"
            >
              <Loader2 v-if="creating" class="animate-spin" :size="18" />
              <Plus v-else :size="18" />
              <span>{{ apiKeys.length >= 5 ? 'Limit Reached' : 'Generate Key' }}</span>
            </button>
          </div>
          <p v-if="apiKeys.length >= 5" class="limit-warning">
            You have reached the maximum limit of 5 API keys. Revoke an existing key to create a new one.
          </p>
        </div>
      </div>

      <!-- Security Notice -->
      <div v-if="!isAdminView" class="security-notice">
        <ShieldAlert :size="18" class="notice-icon" />
        <div class="notice-content">
          <strong>Security Notice:</strong> If you suspect your API key has been compromised, revoke it immediately to prevent unauthorized access and potential system blockage.
        </div>
      </div>

      <!-- Usage Guide -->
      <div v-if="!isAdminView" class="usage-guide">
        <h4>API Usage Guide</h4>
        <p class="guide-description">Use your API key to authenticate requests to the moderation endpoint:</p>
        <div class="code-example">
          <div class="code-header">
            <span>cURL Example</span>
          </div>
          <pre><code>curl -X POST {{ supabaseUrl }}/functions/v1/moderate-image \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "imageUrl": "https://example.com/image.jpg",
    "tasks": "porn_moderation,gore_moderation"
  }'</code></pre>
        </div>
        <p class="endpoint-info">
          <strong>Endpoint:</strong> <code>{{ supabaseUrl }}/functions/v1/moderate-image</code>
        </p>
      </div>

      <div class="table-container">
        <div v-if="loading" class="loading-state">
          <Loader2 class="animate-spin" :size="40" />
          <span>Loading keys...</span>
        </div>

        <div v-else-if="apiKeys.length === 0" class="empty-state">
          <ShieldAlert :size="48" class="text-secondary" />
          <p>No API keys found</p>
          <span v-if="!isAdminView">Create your first key to start using the API</span>
        </div>

        <table v-else class="keys-table">
          <thead>
            <tr>
              <th>Name</th>
              <th v-if="isAdminView">User</th>
              <th v-if="!isAdminView">API Key</th>
              <th>Last Used</th>
              <th>Created</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="key in apiKeys" :key="key.id">
              <td>
                <div class="key-name-cell">
                  <span class="font-bold">{{ key.name }}</span>
                </div>
              </td>
              <td v-if="isAdminView">
                <div class="user-cell">
                  <User :size="14" class="text-secondary" />
                  <span>{{ key.profiles?.email }}</span>
                </div>
              </td>
              <td v-if="!isAdminView">
                <div class="key-display-cell">
                  <code>{{ key.api_key.substring(0, 12) }}...</code>
                  <button @click="copyToClipboard(key.api_key, key.id)" class="btn-copy" :title="copiedId === key.id ? 'Copied!' : 'Copy to clipboard'">
                    <Check v-if="copiedId === key.id" :size="14" class="text-success" />
                    <Copy v-else :size="14" />
                  </button>
                </div>
              </td>
              <td>
                <div class="date-cell">
                  <MousePointerClick :size="14" class="text-secondary" />
                  <span>{{ key.last_used_at ? new Date(key.last_used_at).toLocaleDateString() : 'Never' }}</span>
                </div>
              </td>
              <td>
                <div class="date-cell">
                  <Calendar :size="14" class="text-secondary" />
                  <span>{{ new Date(key.created_at).toLocaleDateString() }}</span>
                </div>
              </td>
              <td>
                <button @click="handleRevokeKey(key.id)" class="btn-revoke" title="Revoke Key">
                  <Trash2 :size="18" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style scoped>
.api-keys-container {
  padding: 24px;
  width: 100%;
}

.dashboard-card {
  padding: 32px;
  width: 100%;
}

.card-header {
  margin-bottom: 32px;
}

.header-flex {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.create-key-section {
  background: var(--surface-hover);
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--border-color);
  margin-bottom: 32px;
}

.label-flex {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.key-count-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--text-secondary);
  background: var(--surface-light);
  padding: 2px 8px;
  border-radius: 4px;
}

.key-count-label.at-limit {
  color: #fb7185;
  background: rgba(244, 63, 94, 0.1);
}

.limit-warning {
  margin-top: 12px;
  font-size: 0.8rem;
  color: #fb7185;
  font-weight: 500;
}

.input-row {
  display: flex;
  gap: 12px;
  margin-top: 12px;
}

.input-wrapper {
  flex: 1;
  position: relative;
}

.input-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-secondary);
}

.input-field {
  width: 100%;
  background: var(--surface-light);
  border: 1px solid var(--border-color);
  padding: 12px 12px 12px 42px;
  border-radius: 12px;
  color: white;
  transition: all 0.2s;
}

.input-field:focus {
  border-color: var(--primary-color);
  outline: none;
}

.create-btn {
  white-space: nowrap;
  padding: 0 24px;
}

.table-container {
  overflow-x: auto;
}

.keys-table {
  width: 100%;
  border-collapse: collapse;
}

.keys-table th {
  text-align: left;
  padding: 16px;
  color: var(--text-secondary);
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 2px solid var(--border-color);
}

.keys-table td {
  padding: 16px;
  border-bottom: 1px solid var(--border-color);
  vertical-align: middle;
}

.key-display-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.key-display-cell code {
  background: var(--surface-hover);
  padding: 4px 8px;
  border-radius: 6px;
  font-family: monospace;
  font-size: 0.85rem;
  color: var(--primary-color);
}

.btn-copy {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.2s;
}

.btn-copy:hover {
  color: white;
  background: var(--surface-hover);
}

.user-cell, .date-cell {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
}

.btn-revoke {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 8px;
  border-radius: 8px;
  transition: all 0.2s;
}

.btn-revoke:hover {
  color: var(--accent-color);
  background: rgba(244, 63, 94, 0.1);
}

.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px;
  gap: 16px;
}

.empty-state p {
  font-weight: 600;
  margin: 0;
}

.empty-state span {
  font-size: 0.85rem;
  color: var(--text-secondary);
}

.text-success { color: #10b981; }

.security-notice {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: rgba(251, 191, 36, 0.1);
  border: 1px solid rgba(251, 191, 36, 0.3);
  border-radius: 12px;
  margin-bottom: 24px;
  align-items: flex-start;
}

.notice-icon {
  color: #fbbf24;
  flex-shrink: 0;
  margin-top: 2px;
}

.notice-content {
  font-size: 0.9rem;
  color: var(--text-primary);
  line-height: 1.5;
}

.notice-content strong {
  color: #fbbf24;
}

.usage-guide {
  background: var(--surface-hover);
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--border-color);
  margin-bottom: 32px;
}

.usage-guide h4 {
  font-size: 1.1rem;
  margin-bottom: 12px;
  color: var(--text-primary);
}

.guide-description {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-bottom: 16px;
}

.code-example {
  background: #000;
  border-radius: 12px;
  border: 1px solid var(--border-color);
  overflow: hidden;
  margin-bottom: 16px;
}

.code-header {
  padding: 10px 16px;
  background: rgba(255, 255, 255, 0.05);
  font-size: 0.75rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid var(--border-color);
}

.code-example pre {
  margin: 0;
  padding: 16px;
  overflow-x: auto;
}

.code-example code {
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  font-size: 0.85rem;
  color: #d1d5db;
  line-height: 1.6;
}

.endpoint-info {
  font-size: 0.9rem;
  color: var(--text-secondary);
}

.endpoint-info code {
  background: rgba(99, 102, 241, 0.1);
  color: var(--primary-color);
  padding: 2px 8px;
  border-radius: 4px;
  font-family: monospace;
  font-size: 0.85rem;
}

@media (max-width: 640px) {
  .input-row {
    flex-direction: column;
  }
}
</style>
