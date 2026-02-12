<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { 
  Users, 
  Coins, 
  Sparkles, 
  ShieldCheck, 
  Ban, 
  CheckCircle,
  Loader2,
  Search
} from 'lucide-vue-next'
import { toast } from 'vue-sonner'

import { authStore } from '../lib/authStore'

const allUsers = ref([])
const loading = ref(true)
const searchQuery = ref('')

// Token Modal State
const showTokenModal = ref(false)
const selectedUser = ref(null)
const newTokenCount = ref(0)
const savingTokens = ref(false)

const fetchAllUsers = async () => {
  loading.value = true
  const { data: usersData } = await supabase
    .from('profiles')
    .select('*')
    .order('updated_at', { ascending: false })
  
  allUsers.value = usersData || []
  loading.value = false
}

onMounted(async () => {
  await fetchAllUsers()
})

const handleUpdateUser = async (u, updates) => {
  if (updates.is_blocked !== undefined && u.id === authStore.session?.user.id) {
    toast.error("You cannot block your own account!")
    return
  }
  
  if (updates.tokens !== undefined) savingTokens.value = true

  try {
    const { error } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', u.id)
    
    if (error) throw error
    
    toast.success('User updated successfully')
    await fetchAllUsers()
    if (showTokenModal.value) showTokenModal.value = false
  } catch (err) {
    toast.error(err.message)
  } finally {
    savingTokens.value = false
  }
}

const openTokenModal = (u) => {
  selectedUser.value = u
  newTokenCount.value = u.tokens || 0
  showTokenModal.value = true
}

const filteredUsers = ref([])

import { watch } from 'vue'
watch([allUsers, searchQuery], () => {
  if (!searchQuery.value) {
    filteredUsers.value = allUsers.value
    return
  }
  const q = searchQuery.value.toLowerCase()
  filteredUsers.value = allUsers.value.filter(u => 
    u.email?.toLowerCase().includes(q) || 
    u.role?.toLowerCase().includes(q)
  )
}, { immediate: true })

</script>

<template>
  <div class="admin-users-container glass fade-in">
    <div class="panel-header">
      <div class="title-with-icon">
        <Users class="icon-accent" :size="24" />
        <h3 class="gradient-text">User Management</h3>
      </div>
      <div class="header-actions">
        <div class="search-box">
          <Search :size="16" />
          <input v-model="searchQuery" type="text" placeholder="Search users..." />
        </div>
        <span class="user-count">{{ filteredUsers.length }} users</span>
      </div>
    </div>

    <div v-if="loading" class="loading-container">
      <Loader2 class="animate-spin" :size="40" />
    </div>

    <div v-else class="table-container">
      <table class="user-table">
        <thead>
          <tr>
            <th>User</th>
            <th>Role</th>
            <th>Tokens</th>
            <th>Last Activity</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="u in filteredUsers" :key="u.id" :class="{ 'is-blocked': u.is_blocked }">
            <td class="user-cell">
              <div class="u-avatar small">
                {{ u.email?.[0].toUpperCase() }}
              </div>
              <div class="u-info-mini">
                <span class="u-email">{{ u.email }}</span>
                <span class="u-date-mini">Joined {{ new Date(u.updated_at).toLocaleDateString() }}</span>
              </div>
            </td>
            <td>
              <span :class="['u-role', u.role]">{{ u.role }}</span>
            </td>
            <td>
              <div class="u-tokens-cell">
                <Coins :size="14" />
                {{ u.tokens || 0 }}
              </div>
            </td>
            <td>
              <div class="u-activity-cell" :title="u.last_login ? new Date(u.last_login).toLocaleString() : 'Never'">
                <Sparkles :size="14" />
                {{ u.last_login ? new Date(u.last_login).toLocaleDateString() : 'Never' }}
              </div>
            </td>
            <td class="actions-cell">
              <div class="admin-actions">
                <button @click="openTokenModal(u)" class="btn-icon" title="Edit tokens">
                  <Coins :size="18" />
                </button>
                
                <button 
                  v-if="u.id !== authStore.session?.user.id"
                  @click="handleUpdateUser(u, { is_blocked: !u.is_blocked })" 
                  class="btn-icon" 
                  :class="u.is_blocked ? 'success' : 'danger'"
                  :title="u.is_blocked ? 'Unblock user' : 'Block user'"
                >
                  <component :is="u.is_blocked ? CheckCircle : Ban" :size="18" />
                </button>
                <div v-else class="self-status-indicator" title="Your account">
                  <ShieldCheck :size="16" />
                </div>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Token Editor Modal -->
    <Teleport to="body">
      <div v-if="showTokenModal" class="modal-overlay" @click.self="showTokenModal = false">
        <div class="modal-content glass">
          <div class="modal-header">
            <div class="title-with-icon">
              <Coins class="icon-accent" :size="24" />
              <h3 class="gradient-text">Manage Tokens</h3>
            </div>
            <p class="modal-subtitle">Updating tokens for {{ selectedUser?.email }}</p>
          </div>

          <div class="modal-body">
            <div class="input-group">
              <label class="input-label">Token Balance</label>
              <div class="token-input-wrapper">
                <input 
                  v-model.number="newTokenCount" 
                  type="number" 
                  min="0"
                  class="input-field"
                  placeholder="0"
                />
                <Coins class="token-icon" :size="20" />
              </div>
            </div>
            <div class="token-presets">
              <button @click="newTokenCount += 100" class="preset-btn">+100</button>
              <button @click="newTokenCount += 500" class="preset-btn">+500</button>
              <button @click="newTokenCount = 0" class="preset-btn danger">Reset</button>
            </div>
          </div>

          <div class="modal-footer">
            <button @click="showTokenModal = false" class="btn-ghost">Cancel</button>
            <button 
              @click="handleUpdateUser(selectedUser, { tokens: newTokenCount })" 
              class="btn-primary"
              :disabled="savingTokens"
            >
              <Loader2 v-if="savingTokens" class="animate-spin" />
              <span v-else>Update Balance</span>
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
.admin-users-container {
  padding: 32px;
  width: 100%;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--border-color);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}

.title-with-icon {
  display: flex;
  align-items: center;
  gap: 12px;
}

.title-with-icon h3 {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0;
}

.icon-accent {
  color: var(--primary-color);
}

.user-count {
  font-size: 0.85rem;
  color: var(--text-secondary);
}

.search-box {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 8px 12px;
}

.search-box input {
  background: transparent;
  border: none;
  color: white;
  font-size: 0.85rem;
  outline: none;
  width: 200px;
}

.table-container {
  overflow-x: auto;
  border-radius: 12px;
}

.user-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
}

.user-table th {
  padding: 16px;
  color: var(--text-secondary);
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
  border-bottom: 2px solid var(--border-color);
}

.user-table td {
  padding: 16px;
  border-bottom: 1px solid var(--border-color);
  vertical-align: middle;
}

.user-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.u-avatar.small {
  width: 32px;
  height: 32px;
  background: var(--primary-color);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  font-weight: 700;
}

.u-info-mini {
  display: flex;
  flex-direction: column;
}

.u-email {
  font-weight: 600;
}

.u-date-mini {
  font-size: 0.7rem;
  color: var(--text-secondary);
}

.u-role {
  font-size: 0.75rem;
  font-weight: 700;
  padding: 4px 8px;
  border-radius: 4px;
  text-transform: uppercase;
}

.u-role.admin {
  background: rgba(244, 63, 94, 0.1);
  color: #fb7185;
}

.u-role.user {
  background: rgba(99, 102, 241, 0.1);
  color: var(--primary-color);
}

.u-tokens-cell {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--primary-color);
  font-weight: 600;
}

.u-activity-cell {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--text-secondary);
  font-size: 0.85rem;
}

.admin-actions {
  display: flex;
  gap: 8px;
}

.btn-icon {
  width: 34px;
  height: 34px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.2s;
}

.btn-icon:hover {
  background: var(--border-color);
  color: white;
}

.btn-icon.danger:hover {
  background: rgba(244, 63, 94, 0.1);
  border-color: var(--accent-color);
  color: var(--accent-color);
}

.btn-icon.success:hover {
  background: rgba(16, 185, 129, 0.1);
  border-color: #10b981;
  color: #10b981;
}

.self-status-indicator {
  color: #10b981;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  width: 100%;
  max-width: 400px;
  padding: 32px;
}

.token-input-wrapper {
  position: relative;
}

.token-icon {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--primary-color);
}

.token-presets {
  display: flex;
  gap: 8px;
  margin-top: 12px;
}

.preset-btn {
  flex: 1;
  padding: 8px;
  border-radius: 6px;
  border: 1px solid var(--border-color);
  background: var(--surface-hover);
  color: white;
  font-size: 0.8rem;
  cursor: pointer;
}

.preset-btn:hover {
  background: var(--border-color);
}

.preset-btn.danger:hover {
  background: rgba(244, 63, 94, 0.1);
  border-color: var(--accent-color);
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 24px;
}

.btn-ghost {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
}

.loading-container {
  display: flex;
  justify-content: center;
  padding: 60px;
}
</style>
