<script setup>
import { Check, ArrowRight } from 'lucide-vue-next'
import { appName } from '../lib/supabase'
</script>

<template>
  <div class="pricing-page container fade-in">
    <header class="section-header">
      <h1>Simple, Scaleable Pricing</h1>
      <p>Only pay for what you moderate. No hidden fees.</p>
    </header>

    <div class="pricing-grid">
      <!-- Starter Tier -->
      <div class="pricing-card glass">
        <div class="tier-name">Starter</div>
        <div class="price">
          <span class="currency">$</span>
          <span class="amount">49</span>
          <span class="period">/mo</span>
        </div>
        <p class="tier-desc">Ideal for small platforms and growing communities.</p>
        <ul class="benefit-list">
          <li><Check :size="16" /> 2,000 images /mo</li>
          <li><Check :size="16" /> Standard Image Moderation</li>
          <li><Check :size="16" /> Email Support</li>
          <li><Check :size="16" /> 2 API Keys</li>
          <li><Check :size="16" /> 30-day History</li>
        </ul>
        <router-link to="/signup" class="btn-secondary text-center-btn">Select Plan</router-link>
      </div>

      <!-- Professional Tier -->
      <div class="pricing-card glass popular">
        <div class="popular-badge">Most Popular</div>
        <div class="tier-name">Professional</div>
        <div class="price">
          <span class="currency">$</span>
          <span class="amount">149</span>
          <span class="period">/mo</span>
        </div>
        <p class="tier-desc">For high-traffic platforms requiring advanced safety.</p>
        <ul class="benefit-list">
          <li><Check :size="16" /> 20,000 images /mo</li>
          <li><Check :size="16" /> Advanced AI Moderation</li>
          <li><Check :size="16" /> Priority Discord Support</li>
          <li><Check :size="16" /> Unlimited API Keys</li>
          <li><Check :size="16" /> Analytics Dashboard</li>
          <li><Check :size="16" /> Custom Webhooks</li>
        </ul>
        <router-link to="/signup" class="btn-primary text-center-btn">Go Professional</router-link>
      </div>

      <!-- Enterprise Tier -->
      <div class="pricing-card glass">
        <div class="tier-name">Enterprise</div>
        <div class="price">
          <span class="amount">Custom</span>
        </div>
        <p class="tier-desc">Dedicated infrastructure and bespoke safety rules.</p>
        <ul class="benefit-list">
          <li><Check :size="16" /> Unlimited requests</li>
          <li><Check :size="16" /> Custom Model Training</li>
          <li><Check :size="16" /> Dedicated Account Manager</li>
          <li><Check :size="16" /> SLA & Legal Guarantees</li>
          <li><Check :size="16" /> On-premise options</li>
        </ul>
        <a :href="`mailto:sales@${appName.toLowerCase().replace(/\s/g, '')}.com`" class="btn-secondary text-center-btn">Contact Sales</a>
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

