<script setup>
import { AlertTriangle, Terminal, ExternalLink, Copy, Check } from 'lucide-vue-next'
import { ref } from 'vue'

const copied = ref(false)
const envExample = `VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key`

const copyToClipboard = () => {
  navigator.clipboard.writeText(envExample)
  copied.value = true
  setTimeout(() => copied.value = false, 2000)
}
</script>

<template>
  <div class="centered-container fade-in">
    <div class="standard-card glass error-card">
      <div class="error-icon-wrapper">
        <AlertTriangle :size="48" class="pulse-icon" />
      </div>
      
      <div class="header-centered">
        <h1 class="gradient-text">Configuration Required</h1>
        <p class="text-secondary">
          NovaModeration needs your Supabase credentials to establish a secure connection to the backend service.
        </p>
      </div>

      <div class="steps-box">
        <div class="step">
          <div class="step-badge">1</div>
          <div class="step-text">Create a <code>.env</code> file in your project root.</div>
        </div>
        <div class="step">
          <div class="step-badge">2</div>
          <div class="step-text">Add your Supabase <strong>URL</strong> and <strong>Anon Key</strong>.</div>
        </div>
      </div>

      <div class="code-block">
        <div class="code-header">
          <div class="dots"><span></span><span></span><span></span></div>
          <button @click="copyToClipboard" class="copy-btn">
            <Check v-if="copied" :size="14" class="success-icon" />
            <Copy v-else :size="14" />
            {{ copied ? 'Copied!' : 'Copy Template' }}
          </button>
        </div>
        <pre class="code-content"><code>{{ envExample }}</code></pre>
      </div>

      <div class="actions">
        <a href="https://supabase.com/dashboard" target="_blank" class="btn-primary" style="width: 100%; text-decoration: none;">
          Open Supabase Dashboard
          <ExternalLink :size="18" />
        </a>
      </div>

      <div class="footer-note">
        <Terminal :size="14" />
        <span>Restart the dev server after saving your <code>.env</code> file.</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.error-card { border: 1px solid rgba(244, 63, 94, 0.3); max-width: 520px; text-align: center; }
.error-icon-wrapper {
  margin-bottom: 24px;
  display: inline-flex;
  padding: 20px;
  background: rgba(244, 63, 94, 0.1);
  border-radius: 50%;
  color: var(--accent-color);
}
.pulse-icon { animation: pulse 2s infinite; }
@keyframes pulse {
  0% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.1); opacity: 0.8; }
  100% { transform: scale(1); opacity: 1; }
}
.steps-box {
  background: var(--surface-color);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 24px;
  text-align: left;
  border: 1px solid var(--border-color);
}
.step { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
.step:last-child { margin-bottom: 0; }
.step-badge {
  width: 24px;
  height: 24px;
  background: var(--primary-color);
  color: white;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  font-weight: 700;
  flex-shrink: 0;
}
.step-text { font-size: 0.95rem; color: var(--text-primary); }
.copy-btn {
  background: none; border: none; color: var(--text-secondary);
  font-size: 0.75rem; cursor: pointer; display: flex; align-items: center; gap: 6px;
  padding: 4px 8px; border-radius: 4px; transition: all 0.2s;
}
.copy-btn:hover { background: rgba(255, 255, 255, 0.1); color: white; }
.success-icon { color: #10b981; }
.footer-note {
  display: flex; align-items: center; justify-content: center; gap: 8px;
  color: var(--text-secondary); font-size: 0.85rem; margin-top: 24px;
}
code { background: rgba(255, 255, 255, 0.1); padding: 2px 6px; border-radius: 4px; font-family: monospace; color: var(--primary-color); }
.text-secondary { color: var(--text-secondary); }
</style>
