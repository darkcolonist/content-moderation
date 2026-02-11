<script setup>
import { Check, ArrowRight } from 'lucide-vue-next'
</script>

<template>
  <div class="pricing-page container fade-in">
    <header class="section-header">
      <h1>Simple, Scaleable Pricing</h1>
      <p>Only pay for what you moderate. No hidden fees.</p>
    </header>

    <div class="pricing-grid">
      <!-- Free Tier -->
      <div class="pricing-card glass">
        <div class="tier-name">Hobby</div>
        <div class="price">
          <span class="currency">$</span>
          <span class="amount">0</span>
          <span class="period">/mo</span>
        </div>
        <p class="tier-desc">Perfect for side projects and early testing.</p>
        <ul class="benefit-list">
          <li><Check :size="16" /> 1,000 requests /mo</li>
          <li><Check :size="16" /> Basic Image Moderation</li>
          <li><Check :size="16" /> Community Support</li>
          <li><Check :size="16" /> Single API Key</li>
        </ul>
        <button class="btn-secondary">Get Started</button>
      </div>

      <!-- Pro Tier -->
      <div class="pricing-card glass popular">
        <div class="popular-badge">Most Popular</div>
        <div class="tier-name">Pro</div>
        <div class="price">
          <span class="currency">$</span>
          <span class="amount">49</span>
          <span class="period">/mo</span>
        </div>
        <p class="tier-desc">For growing apps with active communities.</p>
        <ul class="benefit-list">
          <li><Check :size="16" /> 50,000 requests /mo</li>
          <li><Check :size="16" /> Advanced Moderation</li>
          <li><Check :size="16" /> Priority Support</li>
          <li><Check :size="16" /> Custom Webhooks</li>
          <li><Check :size="16" /> Analytics Dashboard</li>
        </ul>
        <button class="btn-primary">Upgrade to Pro</button>
      </div>

      <!-- Enterprise Tier -->
      <div class="pricing-card glass">
        <div class="tier-name">Enterprise</div>
        <div class="price">
          <span class="amount">Custom</span>
        </div>
        <p class="tier-desc">Dedicated infrastructure for massive scale.</p>
        <ul class="benefit-list">
          <li><Check :size="16" /> Unlimited requests</li>
          <li><Check :size="16" /> Custom Model Training</li>
          <li><Check :size="16" /> 24/7 Phone Support</li>
          <li><Check :size="16" /> SLA Guarantees</li>
        </ul>
        <button class="btn-secondary">Contact Sales</button>
      </div>
    </div>

    <div class="faq-section">
      <h2>Frequently Asked Questions</h2>
      <div class="faq-grid">
        <div class="faq-item">
          <h4>What counts as a "request"?</h4>
          <p>Each individual image or video frame sent to our API counts as one request.</p>
        </div>
        <div class="faq-item">
          <h4>Can I upgrade/downgrade?</h4>
          <p>Yes, you can change your plan at any time. Pricing will be pro-rated.</p>
        </div>
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

h1 {
  font-size: 3rem;
  font-weight: 800;
  margin-bottom: 16px;
}

.section-header p {
  font-size: 1.25rem;
  color: var(--text-secondary);
}

.pricing-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  margin-bottom: 80px;
}

.pricing-card {
  padding: 40px;
  display: flex;
  flex-direction: column;
  position: relative;
}

.popular {
  border-color: var(--primary-color);
  transform: scale(1.05);
  z-index: 10;
  box-shadow: 0 0 40px var(--primary-glow);
}

.popular-badge {
  position: absolute;
  top: -14px;
  left: 50%;
  transform: translateX(-50%);
  background: var(--primary-color);
  color: white;
  padding: 4px 12px;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: 700;
}

.tier-name {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 16px;
  color: var(--text-secondary);
}

.price {
  margin-bottom: 24px;
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.currency { font-size: 1.5rem; color: var(--text-secondary); }
.amount { font-size: 3.5rem; font-weight: 800; }
.period { color: var(--text-secondary); }

.tier-desc {
  color: var(--text-secondary);
  font-size: 0.95rem;
  margin-bottom: 32px;
}

.benefit-list {
  list-style: none;
  margin-bottom: 40px;
  flex: 1;
}

.benefit-list li {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  font-size: 0.9rem;
  color: var(--text-primary);
}

.benefit-list svg {
  color: var(--primary-color);
}

.btn-secondary {
  width: 100%;
  background: var(--surface-hover);
  border: 1px solid var(--border-color);
  color: white;
  padding: 12px;
  border-radius: 12px;
  cursor: pointer;
}

.faq-section {
  border-top: 1px solid var(--border-color);
  padding-top: 80px;
}

.faq-section h2 {
  text-align: center;
  margin-bottom: 48px;
}

.faq-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 48px;
}

.faq-item h4 {
  margin-bottom: 12px;
  font-size: 1.1rem;
}

.faq-item p {
  color: var(--text-secondary);
  line-height: 1.6;
}

@media (max-width: 900px) {
  .pricing-grid { grid-template-columns: 1fr; }
  .popular { transform: none; margin: 24px 0; }
  .faq-grid { grid-template-columns: 1fr; }
}
</style>
