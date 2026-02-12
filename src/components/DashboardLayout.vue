<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase } from '../lib/supabase'
import { 
  User, 
  Shield, 
  History, 
  Users, 
  LayoutDashboard,
  ShieldCheck,
  ChevronLeft,
  ChevronRight,
  Menu,
  X,
  KeyRound
} from 'lucide-vue-next'
import { useRouter, useRoute } from 'vue-router'

import { authStore } from '../lib/authStore'

const router = useRouter()
const route = useRoute()
const isCollapsed = ref(false)
const isMobileOpen = ref(false)

const toggleSidebar = () => {
  if (window.innerWidth <= 768) {
    isMobileOpen.value = !isMobileOpen.value
  } else {
    isCollapsed.value = !isCollapsed.value
  }
}

const closeMobile = () => {
  isMobileOpen.value = false
}

const currentSectionName = computed(() => {
  const allItems = [...navItems, ...adminItems]
  return allItems.find(item => item.path === route.path)?.name || 'Dashboard'
})

const navItems = [
  { name: 'Profile', path: '/profile', icon: User },
  { name: 'Moderate', path: '/moderate', icon: Shield },
  { name: 'My History', path: '/history', icon: History },
  { name: 'API Keys', path: '/api-keys', icon: KeyRound },
]

const adminItems = [
  { name: 'Global History', path: '/admin/history', icon: ShieldCheck },
  { name: 'API Management', path: '/admin/api-keys', icon: KeyRound },
  { name: 'User Management', path: '/admin/users', icon: Users },
]

const isActive = (path) => route.path === path
</script>

<template>
  <div class="dashboard-layout">
    <!-- Mobile Header -->
    <header class="mobile-header glass">
      <button @click="isMobileOpen = true" class="menu-trigger">
        <Menu :size="24" />
      </button>
      <span class="mobile-section-title">{{ currentSectionName }}</span>
      <div class="spacer"></div>
    </header>

    <!-- Overlay -->
    <div v-if="isMobileOpen" class="sidebar-overlay" @click="closeMobile"></div>

    <aside class="sidebar glass" :class="{ collapsed: isCollapsed, 'mobile-open': isMobileOpen }">
      <div class="sidebar-header">
        <div class="logo-group">
          <LayoutDashboard :size="22" class="header-icon" />
          <span v-if="!isCollapsed || isMobileOpen" class="header-text">Dashboard</span>
        </div>
        
        <!-- Mobile Close Button -->
        <button v-if="isMobileOpen" @click="closeMobile" class="mobile-close-btn">
          <X :size="20" />
        </button>
      </div>

      <nav class="sidebar-nav">
        <div class="nav-section">
          <router-link 
            v-for="item in navItems" 
            :key="item.path" 
            :to="item.path"
            class="nav-item"
            :class="{ active: isActive(item.path) }"
            @click="closeMobile"
          >
            <component :is="item.icon" :size="20" />
            <span v-if="!isCollapsed || isMobileOpen">{{ item.name }}</span>
          </router-link>
        </div>

        <div v-if="authStore.profile?.role === 'admin'" class="nav-section admin-section">
          <div v-if="!isCollapsed || isMobileOpen" class="section-label">Administration</div>
          <router-link 
            v-for="item in adminItems" 
            :key="item.path" 
            :to="item.path"
            class="nav-item admin-item"
            :class="{ active: isActive(item.path) }"
            @click="closeMobile"
          >
            <component :is="item.icon" :size="20" />
            <span v-if="!isCollapsed || isMobileOpen">{{ item.name }}</span>
          </router-link>
        </div>
      </nav>

      <div class="sidebar-footer desktop-only">
        <button @click="toggleSidebar" class="collapse-toggle-btn" :title="isCollapsed ? 'Expand' : 'Collapse'">
          <ChevronLeft v-if="!isCollapsed" :size="18" />
          <ChevronRight v-else :size="18" />
          <span v-if="!isCollapsed" class="toggle-text">Minimize Sidebar</span>
        </button>
      </div>
    </aside>

    <main class="dashboard-content">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>
  </div>
</template>

<style scoped>
.dashboard-layout {
  display: flex;
  height: 100%;
  width: 100%;
  background: transparent;
}

.sidebar {
  width: 260px;
  height: calc(100vh - 80px); /* Default for landing page if sidebar is used */
  margin: 10px;
  display: flex;
  flex-direction: column;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 1001;
  border-radius: 20px;
}

/* Specific condensed height for dashboard structure */
.dashboard-layout .sidebar {
  height: calc(100vh - 66px); /* 50px navbar + 16px margins */
}

.is-logged-in .sidebar {
  height: calc(100vh - 60px); /* Adjusted for shorter navbar */
}

.mobile-header {
  display: none;
  position: fixed;
  top: 70px; /* Below main navbar */
  left: 0;
  right: 0;
  height: 56px;
  padding: 0 16px;
  align-items: center;
  justify-content: space-between;
  z-index: 1000;
  border-radius: 0;
  border-left: none;
  border-right: none;
}

.menu-trigger {
  background: transparent;
  border: none;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.mobile-section-title {
  font-weight: 600;
  font-size: 1rem;
  color: white;
}

.spacer {
  width: 24px;
}

.sidebar-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  z-index: 1000;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.mobile-only {
  display: none;
}

@media (max-width: 768px) {
  .mobile-header {
    display: flex;
  }

  .sidebar {
    position: fixed;
    top: 0;
    left: -280px;
    bottom: 0;
    margin: 0;
    height: 100vh;
    border-radius: 0 20px 20px 0;
    width: 260px;
    z-index: 1001;
  }

  .sidebar.mobile-open {
    left: 0;
    box-shadow: 20px 0 50px rgba(0, 0, 0, 0.5);
  }

  .desktop-only {
    display: none;
  }

  .mobile-only {
    display: flex;
  }

  .dashboard-content {
    margin-top: 56px;
    padding: 16px;
  }
}

.sidebar.collapsed {
  width: 80px;
}

.sidebar-header {
  padding: 16px 24px; /* Reduced from 24px */
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid var(--border-color);
  min-height: 60px; /* Reduced from 80px */
}

.logo-group {
  display: flex;
  align-items: center;
  gap: 12px;
}

.sidebar.collapsed .logo-group {
  width: 100%;
  justify-content: center;
}

.header-icon {
  color: var(--primary-color);
  flex-shrink: 0;
}

.header-text {
  font-weight: 700;
  font-size: 1.1rem;
  letter-spacing: -0.02em;
  white-space: nowrap;
}

.mobile-close-btn {
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

.mobile-close-btn:hover {
  color: white;
  border-color: var(--accent-color);
}

.sidebar-footer {
  padding: 16px;
  border-top: 1px solid var(--border-color);
}

.collapse-toggle-btn {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: transparent;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  border-radius: 12px;
  transition: all 0.2s;
  overflow: hidden;
  white-space: nowrap;
}

.collapse-toggle-btn:hover {
  background: var(--surface-hover);
  color: white;
}

.sidebar.collapsed .collapse-toggle-btn {
  justify-content: center;
  padding: 12px 0;
}

.toggle-text {
  font-size: 0.85rem;
  font-weight: 500;
}

.sidebar-nav {
  flex: 1;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 24px;
  overflow-y: auto;
}

.nav-section {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.section-label {
  font-size: 0.7rem;
  text-transform: uppercase;
  color: var(--text-secondary);
  font-weight: 700;
  letter-spacing: 0.05em;
  padding: 8px 12px;
  margin-bottom: 4px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 12px;
  color: var(--text-secondary);
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s;
}

.nav-item:hover {
  background: var(--surface-hover);
  color: white;
}

.nav-item.active {
  background: var(--primary-color);
  color: white;
  box-shadow: 0 4px 12px var(--primary-glow);
}

.admin-item.active {
  background: var(--accent-color);
  box-shadow: 0 4px 12px var(--accent-glow);
}

.dashboard-content {
  flex: 1;
  padding: 10px;
  overflow-y: auto;
  height: calc(100vh - 66px); /* Match sidebar height and shorter nav */
}

.sidebar.collapsed .nav-item {
  justify-content: center;
  padding: 12px 0;
}

.sidebar.collapsed .section-label {
  display: none;
}

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
