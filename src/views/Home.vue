<script setup>
import { RouterLink } from 'vue-router'
import { Rocket, Shield, Zap, CheckCircle, ArrowRight, Star, Eye, AlertTriangle, ShieldCheck } from 'lucide-vue-next'
import { Swiper, SwiperSlide } from 'swiper/vue'
import { Autoplay, Pagination, EffectCoverflow } from 'swiper/modules'
import { appName } from '../lib/supabase'

// Import Swiper styles
import 'swiper/css'
import 'swiper/css/pagination'
import 'swiper/css/effect-coverflow'

const modules = [Autoplay, Pagination, EffectCoverflow]

const showcaseImages = [
  {
    url: '/assets/showcase/sample1.jpg',
    decision: 'OK',
    confidence: 0.999,
    tasks: {
      porn_moderation: '0.001',
      gore_moderation: '0.001',
      weapon_moderation: '0.002'
    }
  },
  {
    url: '/assets/showcase/sample2.jpg',
    decision: 'OK',
    confidence: 0.995,
    tasks: {
      face_detection: '0.998',
      face_gender_detection: '0.995',
      face_age_detection: '0.992'
    }
  },
  {
    url: '/assets/showcase/sample3.jpg',
    decision: 'OK',
    confidence: 0.982,
    tasks: {
      weapon_moderation: '0.015',
      money_moderation: '0.005',
      qr_code_moderation: '0.002'
    }
  },
  {
    url: '/assets/showcase/sample4.jpg',
    decision: 'OK',
    confidence: 0.997,
    tasks: {
      drug_moderation: '0.002',
      obscene_gesture_moderation: '0.001',
      hate_sign_moderation: '0.001'
    }
  },
  {
    url: '/assets/showcase/sample5.jpg',
    decision: 'OK',
    confidence: 0.965,
    tasks: {
      drug_moderation: '0.042',
      gore_moderation: '0.035',
      hate_sign_moderation: '0.012'
    }
  },
  {
    url: '/assets/showcase/sample6.jpg',
    decision: 'FLAGGED',
    confidence: 0.921,
    reason: 'Suggestive Content',
    tasks: {
      suggestive_nudity_moderation: '0.824',
      porn_moderation: '0.052',
      obscene_gesture_moderation: '0.012'
    }
  }
]
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

    <!-- Showcase Section -->
    <section class="showcase-section">
      <div class="section-header">
        <h2 class="gradient-text h2">Moderation in Action</h2>
        <p class="text-secondary">See how our AI analyzes and categorizes images in real-time.</p>
      </div>

      <swiper
        :modules="modules"
        :slides-per-view="1"
        :space-between="30"
        :centered-slides="true"
        :loop="true"
        :autoplay="{
          delay: 3500,
          disableOnInteraction: false,
        }"
        :effect="'coverflow'"
        :coverflow-effect="{
          rotate: 5,
          stretch: 0,
          depth: 100,
          modifier: 2,
          slideShadows: false,
        }"
        :pagination="{ clickable: true }"
        :breakpoints="{
          '768': { slidesPerView: 2 },
          '1024': { slidesPerView: 3 }
        }"
        class="moderation-swiper"
      >
        <swiper-slide v-for="(img, index) in showcaseImages" :key="index">
          <div class="showcase-card glass">
            <div class="image-container">
              <img :src="img.url" alt="Moderated Sample" />
              <div v-if="img.decision === 'FLAGGED'" class="overlay ko">
                <AlertTriangle :size="48" />
                <span>FLAGGED</span>
              </div>
              <div v-else-if="img.decision === 'WARNING'" class="overlay warning">
                <AlertTriangle :size="48" />
                <span>WARNING</span>
              </div>
              <div v-else class="overlay ok">
                <ShieldCheck :size="48" />
                <span>SAFE</span>
              </div>
            </div>
            <div class="card-details">
              <div class="result-header">
                <span class="decision-badge" :class="{
                  'badge-ok': img.decision === 'OK',
                  'badge-ko': img.decision === 'FLAGGED',
                  'badge-warning': img.decision === 'WARNING'
                }">
                  {{ img.decision }}
                </span>
                <span class="confidence">Confidence: {{ (img.confidence * 100).toFixed(1) }}%</span>
              </div>
              <div class="task-results">
                <div v-for="(score, task) in img.tasks" :key="task" class="task-item">
                  <span class="task-name">{{ task.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()) }}</span>
                  <div class="task-progress">
                    <div class="task-fill" :style="{ width: (parseFloat(score) * 100) + '%' }" :class="parseFloat(score) > 0.5 ? 'danger-fill' : 'safe-fill'"></div>
                  </div>
                  <span class="task-score">{{ (parseFloat(score) * 100).toFixed(1) }}%</span>
                </div>
              </div>
              <div v-if="img.reason" class="reason-tag">
                <Eye :size="14" /> {{ img.reason }}
              </div>
            </div>
          </div>
        </swiper-slide>
      </swiper>
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
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 16px;
}

@media (min-width: 768px) {
  .home-page {
    padding: 80px 24px;
  }
}

.hero {
  display: flex;
  flex-direction: column;
  gap: 32px;
  align-items: center;
  margin-bottom: 60px;
  text-align: center;
}

@media (min-width: 1024px) {
  .hero {
    display: grid;
    grid-template-columns: 1.1fr 0.9fr;
    text-align: left;
    gap: 60px;
    margin-bottom: 120px;
  }
}

.hero-title {
  font-size: clamp(2.25rem, 10vw, 4.5rem);
  font-weight: 800;
  line-height: 1.1;
  margin-bottom: 20px;
  letter-spacing: -0.04em;
}

.intelligent {
  color: var(--primary-color);
  -webkit-text-fill-color: initial;
  background: none;
}

.hero-subtitle {
  font-size: clamp(1rem, 4vw, 1.2rem);
  line-height: 1.5;
  margin-bottom: 32px;
  max-width: 540px;
  margin-left: auto;
  margin-right: auto;
  color: var(--text-secondary);
}

@media (min-width: 1024px) {
  .hero-subtitle {
    margin-left: 0;
  }
}

.hero-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 40px;
  width: 100%;
}

@media (min-width: 480px) {
  .hero-actions {
    flex-direction: row;
    justify-content: center;
  }
}

@media (min-width: 1024px) {
  .hero-actions {
    justify-content: flex-start;
  }
}

.btn-large {
  padding: 14px 28px;
  font-size: 1rem;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
}

@media (min-width: 480px) {
  .btn-large {
    width: auto;
  }
}

.trust-indicators {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 12px;
}

@media (min-width: 1024px) {
  .trust-indicators {
    justify-content: flex-start;
    gap: 24px;
  }
}

.trust-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--text-secondary);
  font-size: 0.8rem;
  font-weight: 500;
}

.trust-item svg {
  color: #10b981;
}

/* Hero Visual */
.hero-visual {
  position: relative;
  width: 100%;
  max-width: 460px;
  margin-top: 20px;
}

@media (min-width: 1024px) {
  .hero-visual {
    margin-top: 0;
  }
}

.visual-card {
  width: 100%;
  padding: 0;
  overflow: hidden;
  box-shadow: 0 20px 50px rgba(0,0,0,0.5);
  border-radius: 20px;
  background: #0d0d0d;
  border: 1px solid var(--border-color);
}

.card-header {
  background: rgba(255,255,255,0.03);
  padding: 10px 14px;
  display: flex;
  align-items: center;
  gap: 6px;
  border-bottom: 1px solid var(--border-color);
}

.dot { width: 8px; height: 8px; border-radius: 50%; }
.red { background: #ff5f56; }
.yellow { background: #ffbd2e; }
.green { background: #27c93f; }
.header-title { font-size: 0.7rem; font-weight: 600; color: var(--text-secondary); margin-left: 6px; }

.card-body { padding: 16px; }

.analysis-item { margin-bottom: 14px; }
.analysis-info { display: flex; justify-content: space-between; margin-bottom: 6px; font-size: 0.8rem; font-weight: 600; }
.safe { color: #10b981; }
.risk { color: var(--accent-color); }

.progress-bar { height: 5px; background: rgba(255,255,255,0.05); border-radius: 3px; overflow: hidden; }
.progress { height: 100%; border-radius: 3px; }
.progress.safe { background: #10b981; }
.progress.danger { background: var(--accent-color); }

.status-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 20px;
  font-size: 0.7rem;
  color: var(--text-secondary);
}

.pulse-dot {
  width: 6px;
  height: 6px;
  background: var(--primary-color);
  border-radius: 50%;
  box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.4);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.7); }
  70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(99, 102, 241, 0); }
  100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(99, 102, 241, 0); }
}

.floating-icon {
  position: absolute;
  padding: 10px;
  border-radius: 12px;
  color: var(--primary-color);
  background: rgba(17, 17, 17, 0.8);
  backdrop-filter: blur(8px);
  border: 1px solid var(--border-color);
  z-index: 2;
}

.icon-1 { top: -15px; left: -15px; animation: float 3s ease-in-out infinite; }
.icon-2 { bottom: -15px; right: 15px; animation: float 4s ease-in-out infinite 1s; }
.icon-3 { top: 40%; right: -20px; animation: float 5s ease-in-out infinite 0.5s; display: none; }

@media (min-width: 640px) {
  .icon-3 { display: block; }
}

@keyframes float {
  0% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
  100% { transform: translateY(0); }
}

/* Showcase Section */
.showcase-section {
  margin-bottom: 80px;
}

.section-header {
  text-align: center;
  margin-bottom: 32px;
  padding: 0 16px;
}

.section-header h2 {
  font-size: clamp(1.75rem, 8vw, 3rem);
  font-weight: 800;
  margin-bottom: 12px;
}

.moderation-swiper {
  padding: 20px 10px 60px;
}

/* Swiper Pagination Customization */
:deep(.swiper-pagination-bullet) {
  background: rgba(255, 255, 255, 0.2);
  width: 8px;
  height: 8px;
  opacity: 1;
  transition: all 0.3s ease;
}

:deep(.swiper-pagination-bullet-active) {
  background: var(--primary-color) !important;
  width: 24px;
  border-radius: 4px;
  box-shadow: 0 0 10px var(--primary-color);
}

.showcase-card {
  height: 100%;
  border-radius: 20px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  transition: transform 0.3s ease;
  background: #0d0d0d !important;
  border: 1px solid var(--border-color);
}

.image-container {
  position: relative;
  height: clamp(180px, 40vw, 240px);
  overflow: hidden;
}

.image-container img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.overlay {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-weight: 800;
  font-size: 1.1rem;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
  opacity: 0;
  transition: opacity 0.3s ease;
}

@media (hover: hover) {
  .showcase-card:hover .overlay {
    opacity: 1;
  }
}

@media (max-width: 1023px) {
  .overlay {
    opacity: 1;
    background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
    justify-content: flex-end;
    padding: 16px;
  }
  .overlay svg { display: none; }
}

.overlay.ko { color: #ef4444; }
.overlay.warning { color: #f59e0b; }
.overlay.ok { color: #10b981; }

.card-details {
  padding: 16px;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.decision-badge {
  padding: 3px 10px;
  border-radius: 99px;
  font-size: 0.7rem;
  font-weight: 700;
}

.badge-ok { background: rgba(16, 185, 129, 0.1); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.2); }
.badge-ko { background: rgba(239, 68, 68, 0.1); color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.2); }
.badge-warning { background: rgba(245, 158, 11, 0.1); color: #f59e0b; border: 1px solid rgba(245, 158, 11, 0.2); }

.confidence {
  font-size: 0.7rem;
  color: var(--text-secondary);
  font-weight: 600;
}

.task-results {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.task-item {
  display: grid;
  grid-template-columns: 60px 1fr 35px;
  align-items: center;
  gap: 8px;
  font-size: 0.65rem;
  font-weight: 600;
}

.task-name { text-transform: capitalize; color: var(--text-secondary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

.task-progress {
  height: 4px;
  background: rgba(255,255,255,0.05);
  border-radius: 2px;
  overflow: hidden;
}

.task-fill { height: 100%; border-radius: 2px; }
.safe-fill { background: #10b981; }
.danger-fill { background: #ef4444; }

.task-score { text-align: right; color: var(--text-secondary); }

.reason-tag {
  margin-top: auto;
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.65rem;
  font-weight: 600;
  color: #fbbf24;
  background: rgba(251, 191, 36, 0.1);
  padding: 4px 8px;
  border-radius: 6px;
  width: fit-content;
}

/* Stats */
.stats-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
  padding: 0 16px;
}

@media (min-width: 640px) {
  .stats-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
  }
}

.stat-card {
  padding: 24px;
  text-align: center;
}

.stat-card h3 { font-size: clamp(2rem, 10vw, 3rem); font-weight: 800; margin-bottom: 4px; color: var(--primary-color); }
.stat-card p { font-size: 0.85rem; color: var(--text-secondary); font-weight: 600; }

@media (min-width: 768px) {
  .stat-card p { font-size: 1rem; }
}
</style>


