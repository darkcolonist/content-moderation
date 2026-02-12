<script setup>
import { RouterLink } from 'vue-router'
import { Rocket, Shield, Zap, CheckCircle, ArrowRight, Star } from 'lucide-vue-next'
import { appName } from '../lib/supabase'
</script>

<template>
  <div class="home-page fade-in">
    <!-- Hero Section -->
    <section class="hero">
      <div class="hero-content">
        <div class="badge-pill">Alpha v2.0 is live</div>
        <h1 class="gradient-text hero-title">The Future of Content Safety is <span class="intelligent">Intelligent</span></h1>
        <p class="hero-subtitle text-secondary">
          {{ appName }} provides lightning-fast, AI-driven content moderation for the next generation of digital platforms. 
          Protect your community with 99.9% accuracy.
        </p>
        <div class="hero-actions">
          <router-link to="/signup" class="btn-primary btn-large">
            Get Started Now
            <ArrowRight :size="20" />
          </router-link>
          <router-link to="/features" class="btn-secondary btn-large">
            Explore Features
          </router-link>
        </div>
        
        <!-- Trust Indicators -->
        <div class="trust-indicators">
          <div class="trust-item">
            <CheckCircle :size="16" />
            <span>GDPR Compliant</span>
          </div>
          <div class="trust-item">
            <CheckCircle :size="16" />
            <span>Low Latency</span>
          </div>
          <div class="trust-item">
            <CheckCircle :size="16" />
            <span>High Precision</span>
          </div>
        </div>
      </div>

      <!-- Hero Visual -->
      <div class="hero-visual">
        <div class="visual-card glass">
          <div class="card-header">
            <div class="dot red"></div>
            <div class="dot yellow"></div>
            <div class="dot green"></div>
            <span class="header-title">Live Analysis Engine</span>
          </div>
          <div class="card-body">
            <div class="analysis-item">
              <div class="analysis-info">
                <span class="label">Nudity</span>
                <span class="value safe">0.02%</span>
              </div>
              <div class="progress-bar"><div class="progress safe" style="width: 2%"></div></div>
            </div>
            <div class="analysis-item">
              <div class="analysis-info">
                <span class="label">Violence</span>
                <span class="value safe">0.15%</span>
              </div>
              <div class="progress-bar"><div class="progress safe" style="width: 15%"></div></div>
            </div>
            <div class="analysis-item">
              <div class="analysis-info">
                <span class="label">Offensive Text</span>
                <span class="value risk">88.4%</span>
              </div>
              <div class="progress-bar"><div class="progress danger" style="width: 88%"></div></div>
            </div>
            <div class="status-indicator">
              <div class="pulse-dot"></div>
              <span>Processing live stream...</span>
            </div>
          </div>
        </div>
        <div class="floating-icon icon-1 glass"><Shield :size="32" /></div>
        <div class="floating-icon icon-2 glass"><Zap :size="32" /></div>
        <div class="floating-icon icon-3 glass"><Star :size="32" /></div>
      </div>
    </section>

    <!-- Stats Section -->
    <section class="stats-grid">
      <div class="stat-card glass">
        <h3>50ms</h3>
        <p>Average Latency</p>
      </div>
      <div class="stat-card glass">
        <h3>10M+</h3>
        <p>Moderated Daily</p>
      </div>
      <div class="stat-card glass">
        <h3>99.9%</h3>
        <p>Recall Rate</p>
      </div>
    </section>
  </div>
</template>

<style scoped>
.home-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 80px 24px;
}

.hero {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr;
  gap: 80px;
  align-items: center;
  margin-bottom: 120px;
}

.hero-title {
  font-size: 4.5rem;
  font-weight: 800;
  line-height: 1.1;
  margin-bottom: 24px;
  letter-spacing: -0.04em;
}

.intelligent {
  color: var(--primary-color);
  -webkit-text-fill-color: initial;
  background: none;
}

.hero-subtitle {
  font-size: 1.25rem;
  line-height: 1.6;
  margin-bottom: 40px;
  max-width: 600px;
}

.hero-actions {
  display: flex;
  gap: 16px;
  margin-bottom: 48px;
}

.btn-large {
  padding: 16px 32px;
  font-size: 1.1rem;
}

.trust-indicators {
  display: flex;
  gap: 24px;
}

.trust-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.trust-item svg {
  color: #10b981;
}

/* Hero Visual */
.hero-visual {
  position: relative;
}

.visual-card {
  width: 100%;
  padding: 0;
  overflow: hidden;
  box-shadow: 0 20px 50px rgba(0,0,0,0.5);
}

.card-header {
  background: rgba(255,255,255,0.05);
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  border-bottom: 1px solid var(--border-color);
}

.dot { width: 10px; height: 10px; border-radius: 50%; }
.red { background: #ff5f56; }
.yellow { background: #ffbd2e; }
.green { background: #27c93f; }
.header-title { font-size: 0.8rem; font-weight: 600; color: var(--text-secondary); margin-left: 8px; }

.card-body { padding: 24px; }

.analysis-item { margin-bottom: 20px; }
.analysis-info { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.9rem; font-weight: 600; }
.safe { color: #10b981; }
.risk { color: var(--accent-color); }

.progress-bar { height: 6px; background: rgba(255,255,255,0.05); border-radius: 3px; overflow: hidden; }
.progress { height: 100%; border-radius: 3px; }
.progress.safe { background: #10b981; }
.progress.danger { background: var(--accent-color); }

.status-indicator {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 32px;
  font-size: 0.8rem;
  color: var(--text-secondary);
}

.pulse-dot {
  width: 8px;
  height: 8px;
  background: var(--primary-color);
  border-radius: 50%;
  box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.4);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.7); }
  70% { transform: scale(1); box-shadow: 0 0 0 10px rgba(99, 102, 241, 0); }
  100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(99, 102, 241, 0); }
}

.floating-icon {
  position: absolute;
  padding: 16px;
  border-radius: 16px;
  color: var(--primary-color);
}

.icon-1 { top: -20px; left: -20px; animation: float 3s ease-in-out infinite; }
.icon-2 { bottom: -20px; right: 20px; animation: float 4s ease-in-out infinite 1s; }
.icon-3 { top: 40%; right: -30px; animation: float 5s ease-in-out infinite 0.5s; }

@keyframes float {
  0% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
  100% { transform: translateY(0); }
}

/* Stats */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 32px;
}

.stat-card {
  padding: 40px;
  text-align: center;
}

.stat-card h3 { font-size: 3rem; font-weight: 800; margin-bottom: 8px; color: var(--primary-color); }
.stat-card p { font-size: 1.1rem; color: var(--text-secondary); font-weight: 600; }

@media (max-width: 1024px) {
  .hero { grid-template-columns: 1fr; text-align: center; gap: 40px; }
  .hero-title { font-size: 3.5rem; }
  .hero-subtitle { margin: 0 auto 40px; }
  .hero-actions { justify-content: center; }
  .trust-indicators { justify-content: center; }
  .hero-visual { max-width: 500px; margin: 0 auto; }
}

@media (max-width: 768px) {
  .hero-title { font-size: 2.75rem; }
  .stats-grid { grid-template-columns: 1fr; }
  .hero-actions { flex-direction: column; }
}
</style>
