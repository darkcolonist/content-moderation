# NovaModeration

A premium content moderation suite built with Vue 3, Vite, and Supabase.

## ✨ Features

- 🌑 **Premium Dark Mode**: Deep aesthetics with glassmorphism and atmospheric glow.
- 🔐 **Supabase Auth**: Secure email/password and GitHub OAuth integration.
- 🚀 **Lightning Fast**: Built on the latest Vite 7+ and Vue 3.5+.
- 🎨 **Modern UI**: Custom Vanilla CSS design with Inter typography and Lucide icons.
- 📱 **Responsive**: Fully optimized for mobile and desktop.

## 🛠️ Setup

1. **Clone and Install**:
   ```bash
   npm install
   ```

2. **Supabase Configuration**:
   Create a `.env` file in the root (copied from `.env.example`):
   ```env
   VITE_SUPABASE_URL=your_project_url
   VITE_SUPABASE_ANON_KEY=your_anon_key
   VITE_APP_NAME=NovaModeration # Optional: Defaults to NovaModeration
   ```

3. **Development**:
   ```bash
   npm run dev
   ```

4. **Build**:
   ```bash
   npm run build
   ```

## 🏗️ Project Structure

- `src/lib/supabase.js`: Supabase client initialization.
- `src/components/Auth.vue`: Combined Login/Registration component.
- `src/components/Profile.vue`: User dashboard and profile management.
- `src/style.css`: Global design system and theme variables.

## 🤖 GitHub Actions

This project includes automated workflows for:
- **Baseline CI**: Automatically builds the project on every push and pull request to ensure stability.
- **Deploy to GitHub Pages**: Automatically deploys the latest version to GitHub Pages when changes are pushed to `main`.


## 🌐 SEO & Meta

- Pre-configured meta tags in `index.html`.
- Semantic HTML structure.
- Modern accessibility standards.
