import { createClient } from '@supabase/supabase-js'

export const appName = import.meta.env.VITE_APP_NAME || 'NovaModeration'
export const contactEmail = import.meta.env.VITE_CONTACT_EMAIL || ''

export const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
export const supabaseAnonKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY || import.meta.env.VITE_SUPABASE_ANON_KEY

export const isConfigured = Boolean(
    supabaseUrl &&
    supabaseAnonKey &&
    supabaseUrl !== 'your_supabase_url' &&
    supabaseUrl.length > 0
)

// We export the client, but it will only be functional if configured
export const supabase = isConfigured
    ? createClient(supabaseUrl, supabaseAnonKey)
    : null
