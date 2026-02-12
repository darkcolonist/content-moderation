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

