<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import { supabase, isConfigured, appName } from './lib/supabase'
import ConfigError from './components/ConfigError.vue'
import { Rocket, Loader2, ChevronDown, User, Shield, LogOut, Settings, Menu, X } from 'lucide-vue-next'
import { useRouter } from 'vue-router'
import { Toaster } from 'vue-sonner'

import { authStore } from './lib/authStore'

const showDropdown = ref(false)
const showMobileMenu = ref(false)
const showProfilePanel = ref(false)
const router = useRouter()

onMounted(() => {
  document.title = `${appName} | Premium Content Intelligence`
  // Watch for session changes to handle sign-out redirection
  watch(() => authStore.session, (newSession) => {
    if (!newSession) {
      const publicRoutes = ['/', '/login', '/signup', '/features', '/pricing', '/docs']
      if (!publicRoutes.includes(router.currentRoute.value.path)) {
        router.push('/login')
      }
    }
  })
})

const handleSignOut = async () => {
  await supabase.auth.signOut()
  showDropdown.value = false
  showProfilePanel.value = false
}

const isDashboard = computed(() => {
  const publicRoutes = ['/', '/login', '/signup', '/features', '/pricing', '/docs']
  return !publicRoutes.includes(router.currentRoute.value.path) && authStore.session
})

const closeMobileMenu = () => {
  showMobileMenu.value = false
}

const closeProfilePanel = () => {
  showProfilePanel.value = false
}

const openProfilePanel = () => {
  showProfilePanel.value = true
  showMobileMenu.value = false
}
</script>

<template>
  <div class="app-wrapper" :class="{ 'is-logged-in': isDashboard }">
    <nav class="navbar glass">
      <div class="nav-content">
        <router-link to="/" class="logo" @click="closeMobileMenu">
          <Rocket class="logo-icon" :size="24" />
          <span>{{ appName }}</span>
        </router-link>

        <!-- Mobile: account avatar in topbar (opens slide panel) -->
        <button v-if="!isDashboard && authStore.session" @click="openProfilePanel" class="mobile-account-btn">
          <div class="user-avatar-mini">
            {{ authStore.session.user.email[0].toUpperCase() }}
          </div>
        </button>

        <!-- Mobile Menu Trigger -->
        <button v-if="!isDashboard" class="mobile-menu-btn" @click="showMobileMenu = !showMobileMenu">
          <Menu v-if="!showMobileMenu" :size="24" />
          <X v-else :size="24" />
        </button>

        <div class="nav-links" :class="{ 'mobile-open': showMobileMenu }">
          <router-link to="/features" class="nav-link" @click="closeMobileMenu">Features</router-link>
          <router-link to="/pricing" class="nav-link" @click="closeMobileMenu">Pricing</router-link>
          <router-link to="/docs" class="nav-link" @click="closeMobileMenu">Docs</router-link>
          
          <!-- Desktop: account dropdown -->
          <div v-if="authStore.session" class="account-dropdown-wrapper">
            <button @click="showDropdown = !showDropdown" class="account-trigger glass" :class="{ active: showDropdown }">
              <div class="user-avatar-mini">
                {{ authStore.session.user.email[0].toUpperCase() }}
              </div>
              <span class="user-email-mini">{{ authStore.session.user.email.split('@')[0] }}</span>
              <ChevronDown :size="16" class="chevron" :class="{ rotate: showDropdown }" />
            </button>
            
            <transition name="dropdown">
              <div v-if="showDropdown" class="dropdown-menu" @mouseleave="showDropdown = false">
                <div class="dropdown-header">
                  <span class="dropdown-label">Account</span>
                  <span class="dropdown-email">{{ authStore.session.user.email }}</span>
                </div>
                
                <div class="dropdown-divider"></div>
                
                <router-link to="/profile" class="dropdown-item" @click="showDropdown = false; closeMobileMenu()">
                  <User :size="18" />
                  <span>Account Settings</span>
                </router-link>
                
                <router-link to="/moderate" class="dropdown-item" @click="showDropdown = false; closeMobileMenu()">
                  <Shield :size="18" />
                  <span>Moderate</span>
                </router-link>
                
                <router-link v-if="authStore.profile?.role === 'admin'" to="/admin/users" class="dropdown-item admin" @click="showDropdown = false; closeMobileMenu()">
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
          <div v-else class="auth-btns">
            <router-link to="/signup" class="btn-primary btn-sm" @click="closeMobileMenu">Join {{ appName }}</router-link>
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

    <footer class="footer" :class="{ 'footer-condensed': isDashboard }">
      <p>&copy; 2024 {{ appName }}. Built for the modern web.</p>
    </footer>

    <!-- Mobile Profile Slide Panel -->
    <transition name="profile-overlay">
      <div v-if="showProfilePanel" class="profile-panel-overlay" @click="closeProfilePanel"></div>
    </transition>
    <transition name="profile-panel">
      <div v-if="showProfilePanel && authStore.session" class="profile-panel">
        <div class="profile-panel-header">
          <span class="profile-panel-title">Account</span>
          <button @click="closeProfilePanel" class="profile-panel-close">
            <X :size="20" />
          </button>
        </div>

        <div class="profile-panel-user">
          <div class="profile-panel-avatar">
            {{ authStore.session.user.email[0].toUpperCase() }}
          </div>
          <div class="profile-panel-user-info">
            <span class="profile-panel-name">{{ authStore.session.user.email.split('@')[0] }}</span>
            <span class="profile-panel-email">{{ authStore.session.user.email }}</span>
          </div>
        </div>

        <div class="profile-panel-divider"></div>

        <nav class="profile-panel-nav">
          <router-link to="/profile" class="profile-panel-item" @click="closeProfilePanel">
            <User :size="20" />
            <span>Account Settings</span>
          </router-link>
          <router-link to="/moderate" class="profile-panel-item" @click="closeProfilePanel">
            <Shield :size="20" />
            <span>Moderate</span>
          </router-link>
          <router-link v-if="authStore.profile?.role === 'admin'" to="/admin/users" class="profile-panel-item admin" @click="closeProfilePanel">
            <Settings :size="20" />
            <span>Admin Panel</span>
          </router-link>
        </nav>

        <div class="profile-panel-divider"></div>

        <button @click="handleSignOut" class="profile-panel-item logout">
          <LogOut :size="20" />
          <span>Sign Out</span>
        </button>
      </div>
    </transition>

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
  padding: 12px 24px; /* Reduced from 16px */
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: padding 0.3s ease;
}

.is-logged-in .nav-content {
  padding: 8px 24px;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 700;
  font-size: 1.1rem;
  transition: all 0.3s ease;
  letter-spacing: -0.02em;
  text-decoration: none;
  color: white;
}

.is-logged-in .logo {
  font-size: 1rem;
}

.is-logged-in .logo-icon {
  width: 20px;
  height: 20px;
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
  z-index: 9999;
  box-shadow: 0 10px 40px rgba(0,0,0,0.8);
  transform-origin: top right;
  background: #0d0d0d !important;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
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
  transition: all 0.3s ease;
}

.footer-condensed {
  padding: 12px;
  font-size: 0.75rem;
  background: rgba(0,0,0,0.2);
  border-top: 1px solid var(--border-color);
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

.auth-btns {
  display: flex;
  align-items: center;
  gap: 20px;
}

.btn-sm {
  padding: 8px 16px;
  font-size: 0.85rem;
  border-radius: 10px;
}

/* Mobile account button - hidden on desktop, shown on mobile */
.mobile-account-btn {
  display: none;
}

.profile-panel-overlay {
  display: none;
}

.profile-panel {
  display: none;
}

@media (max-width: 768px) {
  .nav-content {
    padding: 12px 16px;
  }

  .mobile-menu-btn {
    display: flex;
    background: transparent;
    border: none;
    color: white;
    cursor: pointer;
    z-index: 1002;
  }

  /* Mobile account avatar button in the topbar */
  .mobile-account-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--surface-hover);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 6px;
    cursor: pointer;
    margin-left: auto;
    transition: all 0.2s;
    z-index: 1002;
  }

  .mobile-account-btn:hover,
  .mobile-account-btn:active {
    border-color: var(--primary-color);
    background: var(--border-color);
  }

  .nav-links {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(5, 5, 5, 0.95);
    backdrop-filter: blur(20px);
    flex-direction: column;
    justify-content: center;
    gap: 32px;
    padding: 80px 24px;
    transform: translateY(-100%);
    transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 1001;
  }

  .nav-links.mobile-open {
    transform: translateY(0);
  }

  .nav-link {
    font-size: 1.5rem;
    font-weight: 600;
  }

  .auth-btns {
    width: 100%;
    margin-top: 16px;
  }

  .auth-btns .btn-primary {
    width: 100%;
    padding: 16px;
    font-size: 1.1rem;
  }

  /* Hide desktop account dropdown entirely on mobile */
  .account-dropdown-wrapper {
    display: none !important;
  }

  /* Profile slide panel */
  .profile-panel-overlay {
    display: block;
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(4px);
    z-index: 2000;
  }

  .profile-panel {
    display: flex;
    flex-direction: column;
    position: fixed;
    top: 0;
    right: 0;
    bottom: 0;
    width: 300px;
    max-width: 85vw;
    background: #0d0d0d;
    border-left: 1px solid rgba(255, 255, 255, 0.08);
    z-index: 2001;
    box-shadow: -10px 0 40px rgba(0, 0, 0, 0.7);
    padding: 0;
    overflow-y: auto;
  }

  .profile-panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px 20px 16px;
  }

  .profile-panel-title {
    font-size: 0.75rem;
    text-transform: uppercase;
    color: var(--text-secondary);
    font-weight: 700;
    letter-spacing: 0.08em;
  }

  .profile-panel-close {
    background: var(--surface-hover);
    border: 1px solid var(--border-color);
    color: var(--text-secondary);
    border-radius: 8px;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s;
  }

  .profile-panel-close:hover {
    color: white;
    border-color: var(--accent-color);
  }

  .profile-panel-user {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 0 20px 20px;
  }

  .profile-panel-avatar {
    width: 44px;
    height: 44px;
    background: var(--primary-color);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.1rem;
    font-weight: 700;
    color: white;
    flex-shrink: 0;
  }

  .profile-panel-user-info {
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .profile-panel-name {
    font-weight: 600;
    font-size: 1rem;
    color: white;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .profile-panel-email {
    font-size: 0.8rem;
    color: var(--text-secondary);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .profile-panel-divider {
    height: 1px;
    background: var(--border-color);
    margin: 4px 20px;
  }

  .profile-panel-nav {
    display: flex;
    flex-direction: column;
    padding: 12px 12px;
    gap: 2px;
  }

  .profile-panel-item {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 14px 16px;
    border-radius: 12px;
    color: var(--text-secondary);
    text-decoration: none;
    font-size: 0.95rem;
    font-weight: 500;
    transition: all 0.2s;
    border: none;
    background: transparent;
    cursor: pointer;
    width: 100%;
    text-align: left;
  }

  .profile-panel-item:hover {
    background: var(--surface-hover);
    color: white;
  }

  .profile-panel-item.admin:hover {
    color: var(--primary-color);
  }

  .profile-panel-item.logout {
    margin: 0 12px 20px;
    padding: 14px 16px;
    border-radius: 12px;
  }

  .profile-panel-item.logout:hover {
    color: var(--accent-color);
    background: rgba(239, 68, 68, 0.08);
  }

  /* Slide panel transitions */
  .profile-panel-enter-active {
    transition: transform 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  }
  .profile-panel-leave-active {
    transition: transform 0.25s cubic-bezier(0.4, 0, 0.6, 1);
  }
  .profile-panel-enter-from,
  .profile-panel-leave-to {
    transform: translateX(100%);
  }

  .profile-overlay-enter-active {
    transition: opacity 0.3s ease;
  }
  .profile-overlay-leave-active {
    transition: opacity 0.2s ease;
  }
  .profile-overlay-enter-from,
  .profile-overlay-leave-to {
    opacity: 0;
  }
}

.mobile-menu-btn {
  display: none;
}
</style>
