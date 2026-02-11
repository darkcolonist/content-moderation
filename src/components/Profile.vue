<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { LogOut, User, Mail, ShieldCheck, Sparkles } from 'lucide-vue-next'

const user = ref(null)

onMounted(async () => {
  const { data: { user: currentUser } } = await supabase.auth.getUser()
  user.value = currentUser
})

const handleSignOut = async () => {
  await supabase.auth.signOut()
}
</script>

<template>
  <div v-if="user" class="dashboard-container fade-in">
    <div class="user-card glass">
      <div class="profile-header">
        <div class="avatar-glow">
          <div class="avatar">
            <User :size="32" />
          </div>
        </div>
        <h2>Account Settings</h2>
        <p>Manage your presence and authentication</p>
      </div>

      <div class="info-list">
        <div class="info-item">
          <div class="info-icon">
            <Mail :size="18" />
          </div>
          <div class="info-content">
            <span class="label">Email Address</span>
            <span class="value">{{ user.email }}</span>
          </div>
        </div>

        <div class="info-item">
          <div class="info-icon">
            <ShieldCheck :size="18" />
          </div>
          <div class="info-content">
            <span class="label">Authentication Status</span>
            <span class="value status-pill">Verified</span>
          </div>
        </div>

        <div class="info-item">
          <div class="info-icon">
            <Sparkles :size="18" />
          </div>
          <div class="info-content">
            <span class="label">Last Login</span>
            <span class="value">{{ new Date(user.last_sign_in_at).toLocaleString() }}</span>
          </div>
        </div>
      </div>

      <button @click="handleSignOut" class="btn-primary signout-btn">
        <LogOut :size="20" />
        Sign Out
      </button>
    </div>
  </div>
</template>

<style scoped>
.dashboard-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 80px);
  padding: 20px;
}

.user-card {
  width: 100%;
  max-width: 480px;
  padding: 40px;
}

.profile-header {
  text-align: center;
  margin-bottom: 32px;
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

.profile-header h2 {
  font-size: 1.75rem;
  font-weight: 700;
  margin-bottom: 4px;
}

.profile-header p {
  color: var(--text-secondary);
  font-size: 0.9rem;
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

.status-pill {
  color: #10b981;
}

.signout-btn {
  width: 100%;
  background: rgba(244, 63, 94, 0.1);
  color: var(--accent-color);
  border: 1px solid rgba(244, 63, 94, 0.2);
}

.signout-btn:hover {
  background: var(--accent-color);
  color: white;
  box-shadow: 0 8px 16px var(--accent-glow);
}
</style>
