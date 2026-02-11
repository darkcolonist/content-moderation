<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { LogOut, User, Mail, ShieldCheck, Sparkles, ShieldAlert, Users, Calendar, Coins, Ban, CheckCircle, Save, Plus, Minus } from 'lucide-vue-next'
import { toast } from 'vue-sonner'

const user = ref(null)
const profile = ref(null)
const allUsers = ref([])
const loading = ref(true)

// Token Modal State
const showTokenModal = ref(false)
const selectedUser = ref(null)
const newTokenCount = ref(0)
const savingTokens = ref(false)

const fetchAllUsers = async () => {
  const { data: usersData } = await supabase
    .from('profiles')
    .select('*')
    .order('updated_at', { ascending: false })
  
  allUsers.value = usersData || []
}

onMounted(async () => {
  loading.value = true
  const { data: { user: currentUser } } = await supabase.auth.getUser()
  user.value = currentUser

  if (currentUser) {
    // Fetch profile to check role
    const { data: profileData } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', currentUser.id)
      .single()
    
    profile.value = profileData

    // Update last_login for the current user
    await supabase
      .from('profiles')
      .update({ last_login: new Date().toISOString() })
      .eq('id', currentUser.id)

    // If admin, fetch all users
    if (profileData?.role === 'admin') {
      await fetchAllUsers()
    }
  }
  loading.value = false
})

const handleUpdateUser = async (u, updates) => {
  if (updates.is_blocked !== undefined && u.id === user.value.id) {
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

const handleSignOut = async () => {
  await supabase.auth.signOut()
}
</script>

<template>
  <div v-if="user" class="dashboard-container fade-in">
    <div class="dashboard-grid" :class="{ 'admin-view': profile?.role === 'admin' }">
      <!-- Account Settings Card -->
      <div class="standard-card glass">
        <div class="header-centered">
          <div class="avatar-glow">
            <div class="avatar">
              <User :size="32" />
            </div>
          </div>
          <h2 class="gradient-text">Account Settings</h2>
          <p class="text-secondary">Manage your presence and authentication</p>
          <div v-if="profile?.role === 'admin'" class="admin-badge">
            <ShieldAlert :size="14" />
            SERVER ADMIN
          </div>
        </div>

        <div class="info-list">
          <div class="info-item">
            <div class="info-icon">
              <Mail :size="profile?.role === 'admin' ? 16 : 18" />
            </div>
            <div class="info-content">
              <span class="label">Email Address</span>
              <span class="value">{{ user.email }}</span>
            </div>
          </div>

          <div class="info-item">
            <div class="info-icon">
              <ShieldAlert :size="profile?.role === 'admin' ? 16 : 18" />
            </div>
            <div class="info-content">
              <span class="label">Your Role</span>
              <span class="value status-pill" :class="profile?.role">{{ profile?.role || 'Loading...' }}</span>
            </div>
          </div>

          <div class="info-item">
            <div class="info-icon">
              <ShieldCheck :size="profile?.role === 'admin' ? 16 : 18" />
            </div>
            <div class="info-content">
              <span class="label">Authentication Status</span>
              <span class="value status-pill">Verified</span>
            </div>
          </div>

          <div class="info-item">
            <div class="info-icon">
              <Coins :size="profile?.role === 'admin' ? 16 : 18" />
            </div>
            <div class="info-content">
              <span class="label">Moderation Tokens</span>
              <span class="value">{{ profile?.tokens || 0 }}</span>
            </div>
          </div>

          <div v-if="profile?.is_blocked" class="info-item blocked-info">
            <div class="info-icon">
              <Ban :size="profile?.role === 'admin' ? 16 : 18" />
            </div>
            <div class="info-content">
              <span class="label">Status</span>
              <span class="value status-pill blocked">ACCESS BLOCKED</span>
            </div>
          </div>

          <div class="info-item">
            <div class="info-icon">
              <Sparkles :size="profile?.role === 'admin' ? 16 : 18" />
            </div>
            <div class="info-content">
              <span class="label">Last Login</span>
              <span class="value">{{ new Date(user.last_sign_in_at).toLocaleString() }}</span>
            </div>
          </div>
        </div>

        <button @click="handleSignOut" class="btn-primary signout-btn" style="width: 100%;">
          <LogOut :size="20" />
          Sign Out
        </button>
      </div>

      <!-- Admin Dashboard Panel -->
      <div v-if="profile?.role === 'admin'" class="admin-panel glass fade-in">
        <div class="panel-header">
          <div class="title-with-icon">
            <Users class="icon-accent" :size="24" />
            <h3 class="gradient-text">User Management</h3>
          </div>
          <span class="user-count">{{ allUsers.length }} total users</span>
        </div>

        <div class="table-container">
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
              <tr v-for="u in allUsers" :key="u.id" :class="{ 'is-blocked': u.is_blocked }">
                <td class="user-cell">
                  <div class="u-avatar small">
                    {{ u.email?.[0].toUpperCase() }}
                  </div>
                  <div class="u-info-mini">
                    <span class="u-email">{{ u.email }}</span>
                    <span class="u-date-mini">Joined {{ new Date(u.updated_at).toLocaleDateString() }}</span>
                  </div>
                </td>
                <td data-label="Role">
                  <span :class="['u-role', u.role]">{{ u.role }}</span>
                </td>
                <td data-label="Tokens">
                  <div class="u-tokens-cell">
                    <Coins :size="14" />
                    {{ u.tokens || 0 }}
                  </div>
                </td>
                <td data-label="Activity">
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
                      v-if="u.id !== user.id"
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
      </div>
    </div>

    <!-- Token Editor Modal -->
    <Teleport to="body">
      <div v-if="showTokenModal" class="modal-overlay reveal-in" @click.self="showTokenModal = false">
        <div class="modal-content glass">
          <div class="modal-header">
            <div class="title-with-icon">
              <Coins class="icon-accent" :size="24" />
              <h3 class="gradient-text">Manage Tokens</h3>
            </div>
            <p class="modal-subtitle">Updating tokens for {{ selectedUser.email }}</p>
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
                <Coins class="input-icon" :size="20" />
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
.dashboard-container {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: 100%;
  padding: 40px 20px;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 32px;
  width: 100%;
  max-width: 480px; /* Default for normal users */
  transition: max-width 0.4s ease;
}

.dashboard-grid.admin-view {
  max-width: 1200px;
}

@media (min-width: 1024px) {
  .dashboard-grid.admin-view {
    grid-template-columns: 400px 1fr;
  }
}

.admin-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  background: rgba(244, 63, 94, 0.1);
  border: 1px solid rgba(244, 63, 94, 0.2);
  color: #fb7185;
  border-radius: 99px;
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  margin-top: 12px;
}

/* Condensed Sidebar for Admin */
.admin-view .standard-card {
  padding: 24px;
}

.admin-view .avatar-glow {
  width: 60px;
  height: 60px;
}

.admin-view .avatar :deep(svg) {
  width: 24px;
  height: 24px;
}

.admin-view .header-centered h2 {
  font-size: 1.25rem;
}

.admin-view .header-centered p {
  font-size: 0.8rem;
}

.admin-view .info-item {
  padding: 10px 14px;
  gap: 12px;
  border-radius: 10px;
}

.admin-view .info-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
}

.admin-view .info-content .label {
  font-size: 0.65rem;
}

.admin-view .info-content .value {
  font-size: 0.85rem;
}

.avatar-glow {
  width: 80px;
  height: 80px;
  margin: 0 auto 16px;
  position: relative;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
  padding: 2px;
}

.avatar {
  width: 100%;
  height: 100%;
  background: var(--surface-color);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 32px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: var(--surface-hover);
  border-radius: 14px;
  border: 1px solid var(--border-color);
}

.info-icon {
  width: 40px;
  height: 40px;
  background: var(--glass-bg);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-color);
}

.info-content {
  display: flex;
  flex-direction: column;
}

.info-content .label {
  font-size: 0.75rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.info-content .value {
  font-size: 0.95rem;
  font-weight: 500;
}

/* Admin Panel Styles */
.admin-panel {
  padding: 32px;
  display: flex;
  flex-direction: column;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--border-color);
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

/* Admin Table Styles */
.table-container {
  overflow-x: auto;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid var(--border-color);
}

.user-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
  font-size: 0.9rem;
}

.user-table th {
  padding: 16px;
  color: var(--text-secondary);
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
  border-bottom: 2px solid var(--border-color);
}

.user-table td {
  padding: 16px;
  border-bottom: 1px solid var(--border-color);
  vertical-align: middle;
}

.user-table tr {
  transition: background 0.2s;
}

.user-table tr:hover {
  background: var(--surface-hover);
}

.user-table tr.is-blocked {
  opacity: 0.6;
}

.user-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.u-avatar.small {
  width: 32px;
  height: 32px;
  font-size: 0.8rem;
  border-radius: 8px;
}

.u-info-mini {
  display: flex;
  flex-direction: column;
}

.u-email {
  font-weight: 600;
  color: white;
}

.u-date-mini {
  font-size: 0.7rem;
  color: var(--text-secondary);
}

.u-tokens-cell, .u-activity-cell {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--text-secondary);
}

.u-tokens-cell {
  color: var(--primary-color);
  font-weight: 600;
}

.u-activity-cell {
  color: var(--text-secondary);
  opacity: 0.8;
}

.actions-cell {
  width: 120px;
}

@media (max-width: 768px) {
  .user-table, 
  .user-table thead, 
  .user-table tbody, 
  .user-table th, 
  .user-table td, 
  .user-table tr { 
    display: block; 
  }

  .user-table thead {
    display: none;
  }

  .user-table tr {
    margin-bottom: 20px;
    padding: 16px;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 16px;
    border: 1px solid var(--border-color);
  }

  .user-table tr:hover {
    background: rgba(255, 255, 255, 0.05);
  }

  .user-table td {
    border: none;
    padding: 8px 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .user-table td::before {
    content: attr(data-label);
    font-size: 0.7rem;
    font-weight: 700;
    text-transform: uppercase;
    color: var(--text-secondary);
    opacity: 0.6;
  }

  .user-cell {
    padding-bottom: 12px !important;
    border-bottom: 1px solid var(--border-color) !important;
    margin-bottom: 8px;
    display: flex !important;
    justify-content: flex-start !important;
  }

  .user-cell::before {
    display: none;
  }

  .actions-cell {
    width: 100%;
    margin-top: 8px;
    padding-top: 12px !important;
    border-top: 1px solid var(--border-color) !important;
  }
}

.btn-icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--surface-light);
  border: 1px solid var(--border-color);
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.2s;
}

.btn-icon:hover {
  border-color: var(--primary-color);
  color: var(--primary-color);
  transform: translateY(-2px);
}

.btn-icon.danger:hover {
  background: rgba(244, 63, 94, 0.1);
  border-color: #f43f5e;
  color: #fb7185;
}

.btn-icon.success:hover {
  background: rgba(16, 185, 129, 0.1);
  border-color: #10b981;
  color: #34d399;
}

.self-status-indicator {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #10b981;
  background: rgba(16, 185, 129, 0.1);
  border-radius: 10px;
  border: 1px solid rgba(16, 185, 129, 0.2);
}

.admin-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

.signout-btn {
  background: rgba(244, 63, 94, 0.1);
  color: var(--accent-color);
  border: 1px solid rgba(244, 63, 94, 0.2);
}

.signout-btn:hover {
  background: var(--accent-color);
  color: white;
  box-shadow: 0 8px 16px var(--accent-glow);
}

.text-secondary { color: var(--text-secondary); }

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 24px;
}

.modal-content {
  width: 100%;
  max-width: 440px;
  padding: 32px;
  border: 1px solid var(--border-color);
}

.modal-header {
  margin-bottom: 24px;
}

.modal-subtitle {
  color: var(--text-secondary);
  font-size: 0.9rem;
  margin-top: 4px;
}

.modal-body {
  margin-bottom: 32px;
}

.token-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.token-input-wrapper .input-field {
  padding-right: 48px;
  font-size: 1.25rem;
  font-weight: 600;
}

.token-input-wrapper .input-icon {
  position: absolute;
  right: 16px;
  color: var(--primary-color);
  opacity: 0.6;
}

.token-presets {
  display: flex;
  gap: 12px;
  margin-top: 16px;
}

.preset-btn {
  flex: 1;
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  color: white;
  padding: 8px;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.preset-btn:hover {
  border-color: var(--primary-color);
  background: var(--surface-light);
}

.preset-btn.danger:hover {
  border-color: #f43f5e;
  background: rgba(244, 63, 94, 0.1);
  color: #fb7185;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn-ghost {
  background: transparent;
  border: 1px solid transparent;
  color: var(--text-secondary);
  padding: 10px 20px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-ghost:hover {
  color: white;
  background: var(--surface-hover);
}

.admin-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.action-btn.secondary {
  background: rgba(59, 130, 246, 0.1);
  color: var(--primary-color);
  border: 1px solid rgba(59, 130, 246, 0.2);
}

.action-btn.secondary:hover {
  background: var(--primary-color);
  color: white;
}

.reveal-in {
  animation: revealIn 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes revealIn {
  from { opacity: 0; transform: scale(0.95) translateY(10px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}
</style>
