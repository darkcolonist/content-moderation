<script setup>
import { Image, Video, Shield, Zap, Lock, Globe } from 'lucide-vue-next'
</script>

<template>
  <div class="features-page container fade-in">
    <header class="section-header">
      <span class="badge">Capabilities</span>
      <h1>Advanced Moderation Intelligence</h1>
      <p>Scale your platform safety with precision-engineered AI tools.</p>
    </header>

    <div class="feature-grid">
      <!-- Image Moderation -->
      <div class="feature-card main glass">
        <div class="card-icon img-icon">
          <Image :size="32" />
        </div>
        <div class="card-badge active">Available Now</div>
        <h2>Image Moderation</h2>
        <p>Real-time detection of explicit content, violence, and unwanted symbols. Our neural engines process millions of frames with 99.9% accuracy.</p>
        <ul class="feature-list">
          <li>Detect Nudity & NSFW content</li>
          <li>OCR for text in images</li>
          <li>Facial recognition & tagging</li>
          <li>Custom blacklist filtering</li>
        </ul>
      </div>

      <!-- Video Moderation -->
      <div class="feature-card main glass coming-soon">
        <div class="card-icon vid-icon">
          <Video :size="32" />
        </div>
        <div class="card-badge">Coming Q3</div>
        <h2>Video Moderation</h2>
        <p>Dynamic frame-by-frame analysis for live streams and uploaded video content. Integrated safety for the next generation of social media.</p>
        <div class="overlay-text">Scaling processing engines...</div>
      </div>
    </div>

    <div class="mini-features">
      <div class="mini-card glass">
        <Shield :size="20" class="mini-icon" />
        <h3>Privacy First</h3>
        <p>Your data is processed and instantly purged. No storage by default.</p>
      </div>
      <div class="mini-card glass">
        <Zap :size="20" class="mini-icon" />
        <h3>Sub-50ms Latency</h3>
        <p>Globally distributed edge nodes ensure local response times.</p>
      </div>
      <div class="mini-card glass">
        <Globe :size="20" class="mini-icon" />
        <h3>Global Standards</h3>
        <p>Built-in support for regional content regulations and laws.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.container {
  max-width: 1100px;
  margin: 0 auto;
  padding: 80px 24px;
}

.section-header {
  text-align: center;
  margin-bottom: 64px;
}

.badge {
  background: var(--primary-glow);
  color: var(--primary-color);
  padding: 6px 12px;
  border-radius: 99px;
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-bottom: 16px;
  display: inline-block;
}

h1 {
  font-size: 3rem;
  font-weight: 800;
  margin-bottom: 16px;
  background: linear-gradient(135deg, #fff 0%, #a1a1aa 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.section-header p {
  font-size: 1.25rem;
  color: var(--text-secondary);
}

.feature-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  margin-bottom: 64px;
}

.feature-card {
  padding: 40px;
  position: relative;
  overflow: hidden;
}

.card-icon {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}

.img-icon { background: rgba(99, 102, 241, 0.1); color: var(--primary-color); }
.vid-icon { background: rgba(244, 63, 94, 0.1); color: var(--accent-color); }

.card-badge {
  position: absolute;
  top: 24px;
  right: 24px;
  font-size: 0.75rem;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: 6px;
  background: var(--surface-hover);
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
}

.card-badge.active {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
  border-color: rgba(16, 185, 129, 0.2);
}

.feature-card h2 {
  font-size: 1.5rem;
  margin-bottom: 16px;
}

.feature-card p {
  color: var(--text-secondary);
  margin-bottom: 24px;
  line-height: 1.7;
}

.feature-list {
  list-style: none;
}

.feature-list li {
  margin-bottom: 10px;
  position: relative;
  padding-left: 20px;
  font-size: 0.95rem;
}

.feature-list li::before {
  content: "→";
  position: absolute;
  left: 0;
  color: var(--primary-color);
}

.coming-soon {
  opacity: 0.6;
  filter: grayscale(0.5);
}

.overlay-text {
  margin-top: 32px;
  padding: 12px;
  background: rgba(0,0,0,0.3);
  border-radius: 8px;
  font-size: 0.85rem;
  font-family: monospace;
  color: var(--accent-color);
}

.mini-features {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.mini-card {
  padding: 24px;
}

.mini-icon {
  color: var(--primary-color);
  margin-bottom: 16px;
}

.mini-card h3 {
  font-size: 1rem;
  margin-bottom: 8px;
}

.mini-card p {
  font-size: 0.85rem;
  color: var(--text-secondary);
}

@media (max-width: 768px) {
  .feature-grid { grid-template-columns: 1fr; }
  .mini-features { grid-template-columns: 1fr; }
  h1 { font-size: 2.25rem; }
}
</style>
