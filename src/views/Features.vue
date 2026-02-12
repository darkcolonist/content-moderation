<script setup>
import { Image, Video, Shield, Zap, Globe } from 'lucide-vue-next'
</script>

<template>
  <div class="page-container fade-in">
    <header class="header-centered">
      <span class="badge-pill">Capabilities</span>
      <h1 class="gradient-text h1-large">Advanced Moderation Intelligence</h1>
      <p class="text-secondary lead">Scale your platform safety with precision-engineered AI tools.</p>
    </header>

    <div class="feature-grid">
      <!-- Image Moderation -->
      <div class="feature-card glass">
        <div class="card-icon img-icon">
          <Image :size="32" />
        </div>
        <div class="card-status active">Available Now</div>
        <h2>Image Moderation</h2>
        <p class="text-secondary">Real-time detection of explicit content, violence, and unwanted symbols. Our neural engines process millions of frames with 99.9% accuracy.</p>
        <ul class="feature-list">
          <li>Detect Nudity & NSFW content</li>
          <li>OCR for text in images</li>
          <li>Facial recognition & tagging</li>
          <li>Custom blacklist filtering</li>
        </ul>
      </div>

      <!-- Video Moderation -->
      <div class="feature-card glass coming-soon">
        <div class="card-icon vid-icon">
          <Video :size="32" />
        </div>
        <div class="card-status">Coming Q3</div>
        <h2>Video Moderation</h2>
        <p class="text-secondary">Dynamic frame-by-frame analysis for live streams and uploaded video content. Integrated safety for the next generation of social media.</p>
        <div class="overlay-text">Scaling processing engines...</div>
      </div>
    </div>

    <div class="mini-features">
      <div class="mini-card glass">
        <Shield :size="20" class="mini-icon" />
        <h3>Privacy First</h3>
        <p class="text-secondary">Your data is processed and instantly purged. No storage by default.</p>
      </div>
      <div class="mini-card glass">
        <Zap :size="20" class="mini-icon" />
        <h3>Sub-50ms Latency</h3>
        <p class="text-secondary">Globally distributed edge nodes ensure local response times.</p>
      </div>
      <div class="mini-card glass">
        <Globe :size="20" class="mini-icon" />
        <h3>Global Standards</h3>
        <p class="text-secondary">Built-in support for regional content regulations and laws.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-container {
  padding: 60px 20px;
}

@media (min-width: 768px) {
  .page-container {
    padding: 80px 24px;
  }
}

.header-centered {
  margin-bottom: 48px;
  text-align: center;
}

.h1-large {
  font-size: clamp(2.25rem, 6vw, 3.5rem);
  font-weight: 800;
  margin-bottom: 16px;
}

.lead {
  font-size: clamp(1rem, 2vw, 1.25rem);
  max-width: 700px;
  margin: 0 auto;
}

.feature-grid {
  display: flex;
  flex-direction: column;
  gap: 24px;
  margin-bottom: 48px;
}

@media (min-width: 1024px) {
  .feature-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 32px;
    margin-bottom: 64px;
  }
}

.feature-card {
  padding: 32px;
  position: relative;
  overflow: hidden;
  height: 100%;
}

@media (min-width: 768px) {
  .feature-card {
    padding: 40px;
  }
}

.card-icon {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}

.img-icon {
  background: rgba(99, 102, 241, 0.1);
  color: var(--primary-color);
}

.vid-icon {
  background: rgba(244, 63, 94, 0.1);
  color: var(--accent-color);
}

.card-status {
  position: absolute;
  top: 24px;
  right: 24px;
  font-size: 0.7rem;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 6px;
  background: var(--surface-hover);
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
  text-transform: uppercase;
}

.card-status.active {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
  border-color: rgba(16, 185, 129, 0.2);
}

h2 {
  font-size: 1.75rem;
  font-weight: 700;
  margin-bottom: 16px;
}

.feature-list {
  list-style: none;
  margin-top: 24px;
}

.feature-list li {
  margin-bottom: 12px;
  position: relative;
  padding-left: 24px;
  font-size: 0.95rem;
  color: var(--text-secondary);
}

.feature-list li::before {
  content: "→";
  position: absolute;
  left: 0;
  color: var(--primary-color);
  font-weight: 700;
}

.coming-soon {
  opacity: 0.7;
  filter: grayscale(0.5);
}

.overlay-text {
  margin-top: 32px;
  padding: 12px;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 8px;
  font-size: 0.8rem;
  font-family: 'JetBrains Mono', monospace;
  color: var(--accent-color);
  width: fit-content;
}

.mini-features {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

@media (min-width: 768px) {
  .mini-features {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 24px;
  }
}

.mini-card {
  padding: 24px;
  height: 100%;
}

.mini-icon {
  color: var(--primary-color);
  margin-bottom: 16px;
}

.mini-card h3 {
  font-size: 1.1rem;
  margin-bottom: 8px;
  color: var(--text-primary);
}

.mini-card p {
  font-size: 0.9rem;
  line-height: 1.6;
}
</style>
