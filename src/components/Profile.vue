<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { LogOut, User, Mail, ShieldCheck, Sparkles, ShieldAlert, Coins, Ban, Loader2, KeyRound, Save, RotateCcw } from 'lucide-vue-next'
import { toast } from 'vue-sonner'

import { authStore } from '../lib/authStore'

const updating = ref(false)
const newPassword = ref('')
const confirmPassword = ref('')

onMounted(async () => {
  await authStore.fetchProfile(true)
})

const handleUpdatePassword = async () => {
  if (!newPassword.value) {
    toast.error('Please enter a new password')
    return
  }
  if (newPassword.value !== confirmPassword.value) {
    toast.error('Passwords do not match')
    return
  }
  if (newPassword.value.length < 6) {
    toast.error('Password must be at least 6 characters')
    return
  }

  updating.value = true
  try {
    const { error } = await supabase.auth.updateUser({
      password: newPassword.value
    })
    if (error) throw error
    toast.success('Password updated successfully')
    newPassword.value = ''
    confirmPassword.value = ''
  } catch (err) {
    toast.error(err.message)
  } finally {
    updating.value = false
  }
}

const handleSignOut = async () => {
  await supabase.auth.signOut()
}
</script>

<template>
  <div class="profile-container fade-in">
    <div class="dashboard-card glass">
      <div class="card-header">
        <div class="title-with-icon">
          <User class="icon-accent" :size="24" />
          <h3 class="gradient-text">Profile Settings</h3>
        </div>
        <p class="text-secondary">View your account details and update your password</p>
      </div>

      <div v-if="authStore.loading && !authStore.profile" class="loading-container">
        <Loader2 class="animate-spin" :size="40" />
      </div>

      <div v-else-if="authStore.session" class="card-body">
        <div class="profile-grid">
          <!-- Read-only Info -->
          <div class="info-section">
            <h4 class="section-title">Account Information</h4>
            <div class="info-list">
              <div class="info-item">
                <div class="info-icon">
                  <Mail :size="18" />
                </div>
                <div class="info-content">
                  <span class="label">Email Address</span>
                  <span class="value">{{ authStore.session.user.email }}</span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-icon">
                  <ShieldAlert :size="18" />
                </div>
                <div class="info-content">
                  <span class="label">User Role</span>
                  <span class="value status-pill" :class="authStore.profile?.role">{{ authStore.profile?.role || 'User' }}</span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-icon">
                  <Coins :size="18" />
                </div>
                <div class="info-content">
                  <span class="label">Available Tokens</span>
                  <div class="token-value-row">
                    <span class="value">{{ authStore.profile?.tokens || 0 }}</span>
                    <button @click="authStore.fetchProfile(true)" class="inline-refresh-btn" :disabled="authStore.loading">
                      <RotateCcw :size="12" :class="{ 'animate-spin': authStore.loading }" />
                    </button>
                  </div>
                </div>
              </div>

              <div class="info-item">
                <div class="info-icon">
                  <Sparkles :size="18" />
                </div>
                <div class="info-content">
                  <span class="label">Last Activity</span>
                  <span class="value">{{ new Date(authStore.session.user.last_sign_in_at).toLocaleString() }}</span>
                </div>
              </div>
            </div>

            <div v-if="authStore.profile?.role === 'admin'" class="admin-badge-container">
               <div class="admin-badge">
                <ShieldCheck :size="14" />
                SERVER ADMINISTRATOR
              </div>
            </div>
          </div>

          <!-- Edit Password -->
          <div class="edit-section">
            <h4 class="section-title">Change Password</h4>
            <div class="input-group">
              <label class="input-label">New Password</label>
              <div class="input-wrapper">
                <KeyRound :size="18" class="input-icon" />
                <input 
                  v-model="newPassword" 
                  type="password" 
                  placeholder="••••••••"
                  class="input-field"
                  :disabled="updating"
                />
              </div>
            </div>

            <div class="input-group">
              <label class="input-label">Confirm New Password</label>
              <div class="input-wrapper">
                <KeyRound :size="18" class="input-icon" />
                <input 
                  v-model="confirmPassword" 
                  type="password" 
                  placeholder="••••••••"
                  class="input-field"
                  :disabled="updating"
                />
              </div>
            </div>

            <button @click="handleUpdatePassword" class="btn-primary" :disabled="updating || !newPassword">
              <Loader2 v-if="updating" class="animate-spin" :size="18" />
              <Save v-else :size="18" />
              <span>Update Password</span>
            </button>
          </div>
        </div>

        <div class="card-footer">
          <button @click="handleSignOut" class="btn-ghost logout-btn">
            <LogOut :size="18" />
            <span>Sign Out from active session</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.profile-container {
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

.profile-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 48px;
}

@media (max-width: 1024px) {
  .profile-grid {
    grid-template-columns: 1fr;
    gap: 32px;
  }
}

.section-title {
  font-size: 0.9rem;
  text-transform: uppercase;
  color: var(--text-secondary);
  font-weight: 700;
  letter-spacing: 0.05em;
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: var(--surface-hover);
  border-radius: 12px;
  border: 1px solid var(--border-color);
}

.info-icon {
  width: 36px;
  height: 36px;
  background: var(--glass-bg);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-color);
}

.info-content {
  display: flex;
  flex-direction: column;
}

.label {
  font-size: 0.7rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.value {
  font-size: 0.9rem;
  font-weight: 500;
  color: white;
}

.token-value-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.inline-refresh-btn {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2px;
  border-radius: 4px;
}

.inline-refresh-btn:hover {
  color: var(--primary-color);
  background: var(--glass-bg);
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.status-pill {
  width: fit-content;
  padding: 2px 8px;
  border-radius: 4px;
}

.status-pill.admin { background: rgba(244, 63, 94, 0.1); color: #fb7185; }
.status-pill.user { background: rgba(99, 102, 241, 0.1); color: var(--primary-color); }

.admin-badge-container {
  margin-top: 24px;
}

.admin-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 16px;
  background: linear-gradient(135deg, rgba(244, 63, 94, 0.2), rgba(244, 63, 94, 0.05));
  border: 1px solid rgba(244, 63, 94, 0.3);
  color: #fb7185;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.05em;
}

.input-group {
  margin-bottom: 20px;
}

.input-wrapper {
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
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  padding: 12px 12px 12px 42px;
  border-radius: 12px;
  color: white;
  transition: all 0.2s;
}

.input-field:focus {
  border-color: var(--primary-color);
  background: var(--surface-light);
  outline: none;
}

.btn-primary {
  width: 100%;
  margin-top: 8px;
}

.card-footer {
  margin-top: 48px;
  padding-top: 24px;
  border-top: 1px solid var(--border-color);
  display: flex;
  justify-content: flex-start;
}

.logout-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-secondary);
  font-size: 0.85rem;
  padding: 8px 16px;
  border-radius: 8px;
  transition: all 0.2s;
  background: transparent;
  border: none;
  cursor: pointer;
}

.logout-btn:hover {
  color: var(--accent-color);
  background: rgba(244, 63, 94, 0.05);
}

.loading-container {
  display: flex;
  justify-content: center;
  padding: 60px;
}
</style>
