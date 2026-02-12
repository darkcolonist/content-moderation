<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase, isConfigured } from './lib/supabase'
import ConfigError from './components/ConfigError.vue'
import { Rocket, Loader2, ChevronDown, User, Shield, LogOut, Settings } from 'lucide-vue-next'
import { useRouter } from 'vue-router'
import { Toaster } from 'vue-sonner'

import { authStore } from './lib/authStore'

const showDropdown = ref(false)
const router = useRouter()

onMounted(() => {
  // Watch for session changes to handle sign-out redirection
  watch(() => authStore.session, (newSession) => {
    if (!newSession) {
      const publicRoutes = ['/', '/signup', '/features', '/pricing', '/docs']
      if (!publicRoutes.includes(router.currentRoute.value.path)) {
        router.push('/')
      }
    }
  })
})

const handleSignOut = async () => {
  await supabase.auth.signOut()
  showDropdown.value = false
}
</script>

<template>
  <div class="app-wrapper">
    <nav class="navbar glass">
      <div class="nav-content">
        <router-link to="/" class="logo">
          <Rocket class="logo-icon" :size="24" />
          <span>NovaModeration</span>
        </router-link>
        <div class="nav-links">
          <router-link to="/features" class="nav-link">Features</router-link>
          <router-link to="/pricing" class="nav-link">Pricing</router-link>
          <router-link to="/docs" class="nav-link">Docs</router-link>
          
          <div v-if="authStore.session" class="account-dropdown-wrapper">
            <button @click="showDropdown = !showDropdown" class="account-trigger glass" :class="{ active: showDropdown }">
              <div class="user-avatar-mini">
                {{ authStore.session.user.email[0].toUpperCase() }}
              </div>
              <span class="user-email-mini">{{ authStore.session.user.email.split('@')[0] }}</span>
              <ChevronDown :size="16" class="chevron" :class="{ rotate: showDropdown }" />
            </button>
            
            <transition name="dropdown">
              <div v-if="showDropdown" class="dropdown-menu glass" @mouseleave="showDropdown = false">
                <div class="dropdown-header">
                  <span class="dropdown-label">Account</span>
                  <span class="dropdown-email">{{ authStore.session.user.email }}</span>
                </div>
                
                <div class="dropdown-divider"></div>
                
                <router-link to="/profile" class="dropdown-item" @click="showDropdown = false">
                  <User :size="18" />
                  <span>Account Settings</span>
                </router-link>
                
                <router-link to="/moderate" class="dropdown-item" @click="showDropdown = false">
                  <Shield :size="18" />
                  <span>Moderate</span>
                </router-link>
                
                <router-link v-if="authStore.profile?.role === 'admin'" to="/admin/users" class="dropdown-item admin" @click="showDropdown = false">
                  <Settings :size="18" />
                  <span>Admin Panel</span>
                </router-link>

                <div class="dropdown-divider"></div>

                <button @click="handleSignOut" class="dropdown-item logout">
                  <LogOut :size="18" />
                  <span>Sign Out</span>
                </button>
              </div>
            </transition>
          </div>
        </div>
      </div>
    </nav>

    <main class="main-content">
      <div v-if="authStore.loading && !authStore.profile" class="global-loader">
        <Loader2 class="animate-spin" :size="40" />
      </div>
      <ConfigError v-else-if="!isConfigured" />
      <router-view v-else v-slot="{ Component }">
        <component :is="Component" :key="router.currentRoute.value.path" />
      </router-view>
    </main>

    <footer class="footer">
      <p>&copy; 2024 NovaModeration. Built for the modern web.</p>
    </footer>

    <!-- Background Orbs -->
    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>

    <Toaster position="bottom-right" richColors closeButton />
  </div>
</template>

<style>
.app-wrapper {
  position: relative;
  height: 100vh;
  height: 100dvh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.navbar {
  position: sticky;
  top: 0;
  z-index: 100;
  border-radius: 0;
  border-left: none;
  border-right: none;
  border-top: none;
}

.nav-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 700;
  font-size: 1.25rem;
  letter-spacing: -0.02em;
  text-decoration: none;
  color: white;
}

.logo-icon {
  color: var(--primary-color);
}

.nav-links {
  display: flex;
  gap: 32px;
  align-items: center;
}

.nav-link {
  color: var(--text-secondary);
  text-decoration: none;
  font-size: 0.9rem;
  transition: color 0.2s;
}

.nav-link:hover, .router-link-active {
  color: white;
}

.profile-link {
  background: var(--surface-hover);
  padding: 6px 14px;
  border-radius: 8px;
  border: 1px solid var(--border-color);
}

.account-dropdown-wrapper {
  position: relative;
}

.account-trigger {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 6px 12px;
  border-radius: 12px;
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  color: white;
  cursor: pointer;
  transition: all 0.2s;
}

.account-trigger:hover, .account-trigger.active {
  background: var(--border-color);
  border-color: var(--primary-color);
}

.user-avatar-mini {
  width: 24px;
  height: 24px;
  background: var(--primary-color);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: 700;
}

.user-email-mini {
  font-size: 0.9rem;
  font-weight: 500;
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.chevron {
  transition: transform 0.2s;
  color: var(--text-secondary);
}

.chevron.rotate {
  transform: rotate(180deg);
}

.dropdown-menu {
  position: absolute;
  top: calc(100% + 12px);
  right: 0;
  width: 240px;
  padding: 8px;
  z-index: 1000;
  box-shadow: 0 10px 25px rgba(0,0,0,0.5);
  transform-origin: top right;
  background: #111111 !important; /* Solid background to prevent transparency issues */
  border: 1px solid var(--border-color);
}

.dropdown-header {
  padding: 12px 16px;
  display: flex;
  flex-direction: column;
}

.dropdown-label {
  font-size: 0.7rem;
  text-transform: uppercase;
  color: var(--text-secondary);
  font-weight: 700;
  letter-spacing: 0.05em;
}

.dropdown-email {
  font-size: 0.85rem;
  color: white;
  margin-top: 4px;
  overflow: hidden;
  text-overflow: ellipsis;
}

.dropdown-divider {
  height: 1px;
  background: var(--border-color);
  margin: 8px;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 16px;
  border-radius: 8px;
  color: var(--text-secondary);
  text-decoration: none;
  font-size: 0.9rem;
  transition: all 0.2s;
  width: 100%;
  border: none;
  background: transparent;
  cursor: pointer;
  text-align: left;
}

.dropdown-item:hover {
  background: var(--surface-hover);
  color: white;
}

.dropdown-item.admin:hover {
  color: var(--primary-color);
}

.dropdown-item.logout:hover {
  color: var(--accent-color);
}

/* Transitions */
.dropdown-enter-active,
.dropdown-leave-active {
  transition: opacity 0.2s, transform 0.2s;
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px) scale(0.95);
}

.main-content {
  flex: 1;
  position: relative;
  display: flex;
  flex-direction: column;
  overflow-y: auto; /* Allow global scrolling for public pages */
  overflow-x: hidden;
}

.global-loader {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100%;
  color: var(--primary-color);
}

.footer {
  text-align: center;
  padding: 40px;
  color: var(--text-secondary);
  font-size: 0.85rem;
}

/* Atmospheric Background Elements */
.orb {
  position: fixed;
  border-radius: 50%;
  filter: blur(80px);
  z-index: -1;
  opacity: 0.15;
}

.orb-1 {
  width: 400px;
  height: 400px;
  background: var(--primary-color);
  top: -100px;
  right: -100px;
}

.orb-2 {
  width: 300px;
  height: 300px;
  background: var(--accent-color);
  bottom: 0;
  left: -50px;
}

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

@media (max-width: 768px) {
  .nav-links {
    gap: 16px;
  }
}
</style>
