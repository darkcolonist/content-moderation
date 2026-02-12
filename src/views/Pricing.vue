<script setup>
import { Check, Coins, ShieldCheck, Zap, LayoutDashboard, History } from 'lucide-vue-next'
import { appName, contactEmail } from '../lib/supabase'
</script>

<template>
  <div class="pricing-page container fade-in">
    <header class="section-header">
      <h1>Simple Token-Based Pricing</h1>
      <p>Purchase tokens and use them whenever you need. No monthly commitments, no expiry.</p>
    </header>

    <div class="pricing-grid">
      <!-- Starter Pack -->
      <div class="pricing-card glass">
        <div class="tier-name">Starter Pack</div>
        <div class="price">
          <span class="currency">$</span>
          <span class="amount">4.99</span>
        </div>
        <p class="tier-desc">Perfect for small projects and individual developers.</p>
        <ul class="benefit-list">
          <li><Check :size="16" /> 200 Tokens</li>
          <li><Check :size="16" /> 1 Token = 1 Task</li>
          <li><Check :size="16" /> Never Expires</li>
          <li><Check :size="16" /> Max 5 API Keys</li>
          <li><Check :size="16" /> Full Dashboard Access</li>
          <li><Check :size="16" /> 30-Day Moderation History</li>
        </ul>
        <router-link to="/signup" class="btn-secondary text-center-btn">Purchase Pack</router-link>
      </div>

      <!-- Pro Pack -->
      <div class="pricing-card glass popular">
        <div class="popular-badge">Best Value</div>
        <div class="tier-name">Pro Pack</div>
        <div class="price">
          <span class="currency">$</span>
          <span class="amount">24.99</span>
        </div>
        <p class="tier-desc">Ideal for high-traffic apps requiring reliable safety.</p>
        <ul class="benefit-list">
          <li><Check :size="16" /> 1,200 Tokens</li>
          <li><Check :size="16" /> 1 Token = 1 Task</li>
          <li><Check :size="16" /> Never Expires</li>
          <li><Check :size="16" /> Max 5 API Keys</li>
          <li><Check :size="16" /> Full Dashboard Access</li>
          <li><Check :size="16" /> 30-Day Moderation History</li>
        </ul>
        <router-link to="/signup" class="btn-primary text-center-btn">Go Pro</router-link>
      </div>

      <!-- Enterprise -->
      <div class="pricing-card glass">
        <div class="tier-name">Enterprise</div>
        <div class="price">
          <span class="amount">Custom</span>
        </div>
        <p class="tier-desc">Bespoke solutions for large-scale enterprise needs.</p>
        <ul class="benefit-list">
          <li><Check :size="16" /> Unlimited Tokens</li>
          <li><Check :size="16" /> Custom Rate Limits</li>
          <li><Check :size="16" /> Dedicated Infrastructure</li>
          <li><Check :size="16" /> Custom Policy Tuning</li>
          <li><Check :size="16" /> Full Dashboard Access</li>
          <li><Check :size="16" /> Extended History Retention</li>
        </ul>
        <a 
          v-if="contactEmail"
          :href="`mailto:${contactEmail}`" 
          class="btn-secondary text-center-btn"
        >
          Contact Us
        </a>
        <button v-else disabled class="btn-secondary text-center-btn disabled">Contact Unavailable</button>
      </div>
    </div>


    <div class="faq-section">
      <h2>Frequently Asked Questions</h2>
      <div class="faq-grid">
        <div class="faq-item">
          <h4>What counts as a "token"?</h4>
          <p>Each moderation task conducted on an image costs exactly 1 token. For example, checking one image for both pornography and nudity counts as 2 tokens.</p>
        </div>
        <div class="faq-item">
          <h4>Do tokens expire?</h4>
          <p>No, your tokens never expire. They stay in your account balance until you use them.</p>
        </div>
        <div class="faq-item">
          <h4>Is there a limit on API keys?</h4>
          <p>Yes, each user can create up to 5 unique API keys for different environments or projects.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.pricing-page {
  padding: 60px 20px;
}

@media (min-width: 768px) {
  .pricing-page {
    padding: 80px 24px;
  }
}

.section-header {
  text-align: center;
  margin-bottom: 48px;
}

.section-header h1 {
  font-size: clamp(2.25rem, 6vw, 3.5rem);
  font-weight: 800;
  margin-bottom: 16px;
}

.section-header p {
  font-size: clamp(1rem, 2vw, 1.2rem);
  color: var(--text-secondary);
  max-width: 700px;
  margin: 0 auto;
}

.pricing-grid {
  display: flex;
  flex-direction: column;
  gap: 24px;
  margin-bottom: 64px;
}

@media (min-width: 1024px) {
  .pricing-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    align-items: stretch;
    gap: 32px;
    margin-bottom: 80px;
  }
}

.pricing-card {
  padding: 32px;
  display: flex;
  flex-direction: column;
  position: relative;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

@media (min-width: 768px) {
  .pricing-card {
    padding: 40px;
  }
}

.pricing-card.popular {
  border-color: var(--primary-color);
  box-shadow: 0 0 40px var(--primary-glow);
}

@media (min-width: 1024px) {
  .pricing-card.popular {
    transform: scale(1.05);
    z-index: 10;
  }
}

.popular-badge {
  position: absolute;
  top: -14px;
  left: 50%;
  transform: translateX(-50%);
  background: var(--primary-color);
  color: white;
  padding: 6px 16px;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: 700;
  white-space: nowrap;
}

.tier-name {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 12px;
  color: var(--text-secondary);
}

.price {
  margin-bottom: 24px;
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.price .currency {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--text-secondary);
}

.price .amount {
  font-size: clamp(3rem, 5vw, 4rem);
  font-weight: 800;
}

.tier-desc {
  font-size: 0.95rem;
  color: var(--text-secondary);
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
  margin-bottom: 16px;
  font-size: 0.9rem;
  color: var(--text-primary);
}

.benefit-list svg {
  color: var(--primary-color);
  flex-shrink: 0;
}

.text-center-btn {
  width: 100%;
  text-align: center;
  text-decoration: none;
  font-weight: 700;
}

.faq-section {
  border-top: 1px solid var(--border-color);
  padding-top: 64px;
}

@media (min-width: 768px) {
  .faq-section {
    padding-top: 80px;
  }
}

.faq-section h2 {
  text-align: center;
  font-size: clamp(1.75rem, 4vw, 2.5rem);
  margin-bottom: 40px;
}

.faq-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 32px;
}

@media (min-width: 768px) {
  .faq-grid {
    grid-template-columns: 1fr 1fr;
    gap: 48px;
  }
}

.faq-item h4 {
  font-size: 1.1rem;
  margin-bottom: 12px;
  color: var(--text-primary);
}

.faq-item p {
  font-size: 0.95rem;
  color: var(--text-secondary);
  line-height: 1.6;
}
</style>




