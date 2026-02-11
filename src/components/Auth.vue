<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { LogIn, UserPlus, Loader2 } from 'lucide-vue-next'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const email = ref('')
const password = ref('')
const error = ref(null)

// Sync with route for initial load and subsequent changes
const isRegister = computed(() => route.path === '/signup' || route.path.includes('signup'))

onMounted(() => {
  console.log('Auth component mounted on:', route.path)
})

const handleAuth = async () => {
  loading.value = true
  error.value = null
  
  try {
    if (isRegister.value) {
      const { error: signUpError } = await supabase.auth.signUp({
        email: email.value,
        password: password.value,
        options: {
          emailRedirectTo: window.location.origin
        }
      })
      if (signUpError) throw signUpError
      alert('Confirmation email sent! Please check your inbox.')
    } else {
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value,
      })
      if (signInError) throw signInError
      router.push('/profile')
    }
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const toggleAuthMode = () => {
  error.value = null
  router.push(isRegister.value ? '/' : '/signup')
}

const handleOAuthLogin = async (provider) => {
  error.value = null
  const { error: oauthError } = await supabase.auth.signInWithOAuth({
    provider: provider,
    options: {
      redirectTo: window.location.origin
    }
  })
  if (oauthError) error.value = oauthError.message
}

onMounted(() => {
  // Catch errors passed back in the URL from failed OAuth attempts
  const hash = window.location.hash
  const params = new URLSearchParams(hash.includes('?') ? hash.split('?')[1] : '')
  
  const errorMsg = params.get('error_description') || params.get('error')
  if (errorMsg) {
    error.value = errorMsg.replace(/\+/g, ' ')
  }
  
  console.log('Auth component mounted on:', route.path)
})
</script>

<template>
  <div class="auth-container fade-in">
    <div class="auth-card glass">
      <div class="auth-header">
        <h1>{{ isRegister ? 'Join the Future' : 'Welcome Back' }}</h1>
        <p>{{ isRegister ? 'Create your account to get started' : 'Sign in to your account to continue' }}</p>
      </div>

      <form @submit.prevent="handleAuth" class="auth-form">
        <div class="input-group">
          <label class="input-label">Email Address</label>
          <input 
            v-model="email" 
            type="email" 
            placeholder="name@example.com" 
            class="input-field"
            required
          />
        </div>

        <div class="input-group">
          <label class="input-label">Password</label>
          <input 
            v-model="password" 
            type="password" 
            placeholder="••••••••" 
            class="input-field"
            required
          />
        </div>

        <div v-if="error" class="error-message">
          {{ error }}
        </div>

        <button type="submit" class="btn-primary auth-submit" :disabled="loading">
          <Loader2 v-if="loading" class="animate-spin" />
          <template v-else>
            <component :is="isRegister ? UserPlus : LogIn" :size="20" />
            {{ isRegister ? 'Create Account' : 'Sign In' }}
          </template>
        </button>
      </form>

      <div class="divider">
        <span>or continue with</span>
      </div>

      <button @click="handleOAuthLogin('google')" class="btn-secondary google-btn">
        <svg class="google-icon" viewBox="0 0 24 24" width="20" height="20">
          <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
          <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
          <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
          <path d="M12 5.38c1.62 0 3.06.56 4.21 1.66l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
        </svg>
        Sign in with Google
      </button>

      <div class="auth-footer">
        <p>
          {{ isRegister ? 'Already have an account?' : "Don't have an account?" }}
          <button @click="toggleAuthMode" class="text-btn">
            {{ isRegister ? 'Sign In' : 'Sign Up' }}
          </button>
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.auth-container {
  display: flex;
  justify-content: center;
  align-items: center;
  flex: 1;
  padding: 24px;
  min-height: min-content;
}

.auth-card {
  width: 100%;
  max-width: 440px;
  padding: 40px;
  margin: auto;
  animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.auth-header {
  text-align: center;
  margin-bottom: 32px;
}

.auth-header h1 {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 8px;
  background: linear-gradient(135deg, #fff 0%, #a1a1aa 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.auth-header p {
  color: var(--text-secondary);
  font-size: 0.95rem;
}

.auth-form {
  margin-bottom: 24px;
}

.auth-submit {
  width: 100%;
  margin-top: 8px;
}

.divider {
  position: relative;
  text-align: center;
  margin: 24px 0;
}

.divider::before {
  content: "";
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 1px;
  background: var(--border-color);
}

.divider span {
  position: relative;
  background: #111; /* Match surface color roughly */
  padding: 0 12px;
  color: var(--text-secondary);
  font-size: 0.85rem;
}

.btn-secondary {
  width: 100%;
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  color: white;
  padding: 12px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.2s;
}

.google-btn {
  gap: 12px;
  background: var(--surface-hover) !important;
  color: white !important;
  border: 1px solid var(--border-color) !important;
}

.google-btn:hover {
  background: var(--border-color) !important;
  border-color: var(--text-secondary) !important;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
}

.btn-secondary:hover:not(.google-btn) {
  background: var(--border-color);
}

.auth-footer {
  margin-top: 32px;
  text-align: center;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.text-btn {
  background: none;
  border: none;
  color: var(--primary-color);
  font-weight: 600;
  cursor: pointer;
  padding: 0;
  margin-left: 4px;
}

.text-btn:hover {
  text-decoration: underline;
}

.error-message {
  background: rgba(244, 63, 94, 0.1);
  color: var(--accent-color);
  padding: 12px;
  border-radius: 8px;
  font-size: 0.85rem;
  margin-bottom: 16px;
  border: 1px solid rgba(244, 63, 94, 0.2);
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>
