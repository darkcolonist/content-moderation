<script setup>
import { ref, onMounted } from 'vue'
import { supabase, isConfigured } from './lib/supabase'
import ConfigError from './components/ConfigError.vue'
import { Rocket, Loader2 } from 'lucide-vue-next'
import { useRouter } from 'vue-router'

const session = ref(null)
const loading = ref(true)
const router = useRouter()

onMounted(async () => {
  if (!isConfigured) {
    loading.value = false
    return
  }

  try {
    const { data } = await supabase.auth.getSession()
    session.value = data.session
    
    if (data.session && (router.currentRoute.value.path === '/' || router.currentRoute.value.path === '/signup')) {
      router.push('/profile')
    }
  } catch (err) {
    console.error('Session check failed:', err)
  } finally {
    loading.value = false
  }

  supabase.auth.onAuthStateChange((_event, _session) => {
    session.value = _session
    if (_session) {
      if (router.currentRoute.value.path === '/' || router.currentRoute.value.path === '/signup') {
        router.push('/profile')
      }
    } else {
      const publicRoutes = ['/', '/signup', '/features', '/pricing', '/docs']
      if (!publicRoutes.includes(router.currentRoute.value.path)) {
        router.push('/')
      }
    }
  })
})
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
          <router-link v-if="session" to="/profile" class="nav-link profile-link">Account</router-link>
        </div>
      </div>
    </nav>

    <main class="main-content">
      <div v-if="loading" class="global-loader">
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

.main-content {
  flex: 1;
  overflow-y: auto;
  position: relative;
  display: flex;
  flex-direction: column;
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
