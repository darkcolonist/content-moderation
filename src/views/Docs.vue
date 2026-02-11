<script setup>
import { Book, Terminal, MessageSquare } from 'lucide-vue-next'
</script>

<template>
  <div class="page-container fade-in">
    <div class="docs-layout">
      <aside class="docs-sidebar">
        <div class="sidebar-group">
          <h5>Getting Started</h5>
          <ul>
            <li class="active">Introduction</li>
            <li>Authentication</li>
            <li>Quick Start Guide</li>
          </ul>
        </div>
        <div class="sidebar-group">
          <h5>Core API</h5>
          <ul>
            <li>Image Moderation</li>
            <li>Video Moderation</li>
            <li>Webhook Integration</li>
          </ul>
        </div>
      </aside>

      <main class="docs-content">
        <header class="content-header">
          <span class="breadcrumb">Docs / Getting Started</span>
          <h1 class="gradient-text">Introduction</h1>
          <p class="text-secondary lead">Welcome to the NovaModeration API documentation. Learn how to integrate our AI safety tools into your application.</p>
        </header>

        <section class="docs-section">
          <h2>Overview</h2>
          <p class="text-secondary">NovaModeration provides a robust set of REST APIs for real-time content analysis. Whether you're building a social network, an e-commerce platform, or a private community, our tools help you maintain safety standards at scale.</p>
          
          <div class="info-box glass">
            <Book :size="20" />
            <p><strong>Note:</strong> Currently, Image Moderation is in General Availability. Video Moderation is available for Early Access partners.</p>
          </div>
        </section>

        <section class="docs-section">
          <h2>Authentication</h2>
          <p class="text-secondary">All API requests must be authenticated using an API key provided in your dashboard. Include the key in the <code>X-API-KEY</code> header.</p>
          
          <div class="code-block">
            <div class="code-header">
              <span>Example Request</span>
              <Terminal :size="14" />
            </div>
            <pre class="code-content"><code>curl -X POST https://api.novamode.ai/v1/image \
  -H "X-API-KEY: YOUR_API_KEY" \
  -F "image=@photo.jpg"</code></pre>
          </div>
        </section>

        <div class="docs-footer">
          <div class="footer-card glass">
            <MessageSquare :size="24" />
            <div>
              <h4>Need help?</h4>
              <p class="text-secondary">Join our Discord community or contact support.</p>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<style scoped>
.docs-layout { display: grid; grid-template-columns: 240px 1fr; gap: 64px; }
.docs-sidebar { position: sticky; top: 100px; height: fit-content; }
.sidebar-group { margin-bottom: 32px; }
.sidebar-group h5 { color: var(--text-primary); font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 16px; }
.sidebar-group ul { list-style: none; }
.sidebar-group li { color: var(--text-secondary); font-size: 0.9rem; padding: 8px 0; cursor: pointer; transition: color 0.2s; }
.sidebar-group li:hover, .sidebar-group li.active { color: var(--primary-color); }
.docs-content { max-width: 800px; }
.content-header { margin-bottom: 48px; }
.breadcrumb { font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 12px; display: block; }
h1 { font-size: 2.5rem; margin-bottom: 16px; }
.lead { font-size: 1.2rem; line-height: 1.6; }
.docs-section { margin-bottom: 64px; }
.docs-section h2 { font-size: 1.75rem; margin-bottom: 24px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px; }
.docs-section p { line-height: 1.8; margin-bottom: 24px; }
.info-box svg { color: var(--primary-color); flex-shrink: 0; }
.info-box p { margin: 0; font-size: 0.95rem; }
.docs-footer { margin-top: 80px; padding-top: 40px; border-top: 1px solid var(--border-color); }
.footer-card { display: flex; align-items: center; gap: 24px; padding: 32px; border-radius: 16px; }
.footer-card h4 { margin-bottom: 4px; }
.text-secondary { color: var(--text-secondary); }

@media (max-width: 900px) {
  .docs-layout { grid-template-columns: 1fr; }
  .docs-sidebar { display: none; }
}
</style>
