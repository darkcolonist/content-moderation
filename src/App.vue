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
}

const isDashboard = computed(() => {
  const publicRoutes = ['/', '/login', '/signup', '/features', '/pricing', '/docs']
  return !publicRoutes.includes(router.currentRoute.value.path) && authStore.session
})

const closeMobileMenu = () => {
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

        <!-- Mobile Menu Trigger -->
        <button v-if="!isDashboard" class="mobile-menu-btn" @click="showMobileMenu = !showMobileMenu">
          <Menu v-if="!showMobileMenu" :size="24" />
          <X v-else :size="24" />
        </button>

        <div class="nav-links" :class="{ 'mobile-open': showMobileMenu }">
          <router-link to="/features" class="nav-link" @click="closeMobileMenu">Features</router-link>
          <router-link to="/pricing" class="nav-link" @click="closeMobileMenu">Pricing</router-link>
          <router-link to="/docs" class="nav-link" @click="closeMobileMenu">Docs</router-link>
          
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

  .account-dropdown-wrapper {
    width: 100%;
  }

  .account-trigger {
    width: 100%;
    justify-content: center;
    padding: 12px;
  }

  .dropdown-menu {
    position: static;
    width: 100%;
    transform: none;
    margin-top: 12px;
    box-shadow: none;
    background: rgba(255, 255, 255, 0.03) !important;
  }
}

.mobile-menu-btn {
  display: none;
}
</style>
