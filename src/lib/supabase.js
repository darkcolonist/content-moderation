import { createClient } from '@supabase/supabase-js'

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
