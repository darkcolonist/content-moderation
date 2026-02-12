<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { LogIn, UserPlus, Loader2 } from 'lucide-vue-next'
import { useRouter, useRoute } from 'vue-router'
import { toast } from 'vue-sonner'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const email = ref('')
const password = ref('')
const error = ref(null)
const showEmailLogin = ref(false)

const isRegister = computed(() => route.path === '/signup' || route.path.includes('signup'))

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
      toast.success('Confirmation email sent! Please check your inbox.')
    } else {
      const { data: { user: authUser }, error: signInError } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value,
      })
      if (signInError) throw signInError

      // Check if user is blocked in profiles
      const { data: profileData } = await supabase
        .from('profiles')
        .select('is_blocked')
        .eq('id', authUser.id)
        .single()
      
      if (profileData?.is_blocked) {
        await supabase.auth.signOut()
        throw new Error('This account has been blocked by an administrator.')
      }

      toast.success('Successfully signed in!')
      router.push('/profile')
    }
  } catch (err) {
    error.value = err.message
    toast.error(err.message)
  } finally {
    loading.value = false
  }
}

const toggleAuthMode = () => {
  error.value = null
  router.push(isRegister.value ? '/login' : '/signup')
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
  const hash = window.location.hash
  const params = new URLSearchParams(hash.includes('?') ? hash.split('?')[1] : '')
  const errorMsg = params.get('error_description') || params.get('error')
  if (errorMsg) {
    error.value = errorMsg.replace(/\+/g, ' ')
  }
})
</script>

<template>
  <div class="centered-container fade-in">
    <div class="standard-card glass">
      <div class="header-centered">
        <h1 class="gradient-text">{{ isRegister ? 'Join the Future' : 'Welcome Back' }}</h1>
        <p class="text-secondary">{{ isRegister ? 'Sign up with your Gmail account to get started with 3 free tokens' : 'Sign in to your account to continue' }}</p>
      </div>

      <!-- Special Offer Banner (Signup Only) -->
      <div v-if="isRegister" class="token-offer-banner">
        <div class="offer-icon">🎁</div>
        <div class="offer-content">
          <h3>Sign up today and get 3 free tokens!</h3>
          <p>Start moderating images immediately with your welcome bonus</p>
        </div>
      </div>

      <!-- Gmail OAuth Button (Primary for both signup and login) -->
      <button @click="handleOAuthLogin('google')" class="btn-secondary google-btn" :class="{ 'primary-cta': isRegister || !isRegister }">
        <svg class="google-icon" viewBox="0 0 24 24" width="20" height="20">
          <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
          <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
          <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
          <path d="M12 5.38c1.62 0 3.06.56 4.21 1.66l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
        </svg>
        {{ isRegister ? 'Sign up with Google' : 'Sign in with Google' }}
      </button>

      <!-- Email/Password Login (Collapsible for login page only) -->
      <div v-if="!isRegister" class="alternative-login">
        <button @click="showEmailLogin = !showEmailLogin" class="toggle-email-btn">
          {{ showEmailLogin ? '− Hide other ways to sign in' : '+ Other ways to sign in' }}
        </button>

        <transition name="slide-down">
          <form v-if="showEmailLogin" @submit.prevent="handleAuth" class="auth-form">
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

            <button type="submit" class="btn-primary" :disabled="loading" style="width: 100%;">
              <Loader2 v-if="loading" class="animate-spin" />
              <template v-else>
                <LogIn :size="20" />
                Sign In
              </template>
            </button>
          </form>
        </transition>
      </div>

      <div v-if="error && isRegister" class="error-message" style="margin-top: 16px;">
        {{ error }}
      </div>

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
.auth-form { margin-top: 24px; }
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
  background: var(--surface-color);
  padding: 0 12px;
  color: var(--text-secondary);
  font-size: 0.85rem;
}
.google-btn {
  width: 100%;
  gap: 12px;
}
.google-btn.primary-cta {
  background: var(--primary-color);
  border-color: var(--primary-color);
  color: white;
  font-weight: 600;
  box-shadow: 0 4px 16px var(--primary-glow);
  transition: all 0.3s;
}
.google-btn.primary-cta:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 24px var(--primary-glow);
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
.text-btn:hover { text-decoration: underline; }
.animate-spin { animation: spin 1s linear infinite; }
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
.text-secondary { color: var(--text-secondary); }

/* Token Offer Banner */
.token-offer-banner {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  margin-bottom: 24px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  border: 2px solid var(--primary-color);
  border-radius: 16px;
  position: relative;
  overflow: hidden;
}

.token-offer-banner::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, transparent 0%, rgba(99, 102, 241, 0.05) 100%);
  pointer-events: none;
}

.offer-icon {
  font-size: 2.5rem;
  flex-shrink: 0;
  animation: bounce 2s ease-in-out infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

.offer-content {
  flex: 1;
  position: relative;
  z-index: 1;
}

.offer-content h3 {
  font-size: 1.1rem;
  font-weight: 700;
  color: white;
  margin: 0 0 4px 0;
  line-height: 1.3;
}

.offer-content p {
  font-size: 0.85rem;
  color: var(--text-secondary);
  margin: 0;
  line-height: 1.4;
}

/* Alternative Login Section */
.alternative-login {
  margin-top: 24px;
}

.toggle-email-btn {
  width: 100%;
  padding: 12px;
  background: transparent;
  border: 1px solid var(--border-color);
  border-radius: 12px;
  color: var(--text-secondary);
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  text-align: center;
}

.toggle-email-btn:hover {
  border-color: var(--primary-color);
  color: white;
  background: var(--surface-hover);
}

/* Slide Down Transition */
.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.3s ease;
  overflow: hidden;
}

.slide-down-enter-from,
.slide-down-leave-to {
  max-height: 0;
  opacity: 0;
  margin-top: 0;
}

.slide-down-enter-to,
.slide-down-leave-from {
  max-height: 500px;
  opacity: 1;
  margin-top: 16px;
}
</style>
