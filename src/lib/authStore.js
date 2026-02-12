import { reactive, watch } from 'vue'
import { supabase } from './supabase'

const CACHE_KEY = 'sb_profile_cache'
const CACHE_DURATION = 60 * 60 * 1000 // 60 minutes in ms

export const authStore = reactive({
    profile: null,
    loading: false,
    error: null,
    session: null,

    async fetchProfile(force = false) {
        if (!this.session?.user) {
            this.profile = null
            return null
        }

        // 1. Check if we already have it in memory and not forcing
        if (this.profile && !force) return this.profile

        // 2. Check localStorage cache
        const cached = localStorage.getItem(CACHE_KEY)
        if (cached && !force) {
            try {
                const { data, timestamp, userId } = JSON.parse(cached)
                const age = Date.now() - timestamp
                // Ensure the cache belongs to the current user and isn't expired
                if (userId === this.session.user.id && age < CACHE_DURATION) {
                    this.profile = data
                    return data
                }
            } catch (e) {
                console.error('Failed to parse auth cache', e)
                localStorage.removeItem(CACHE_KEY)
            }
        }

        // 3. Fetch from Supabase
        this.loading = true
        try {
            const { data, error } = await supabase
                .from('profiles')
                .select('*')
                .eq('id', this.session.user.id)
                .single()

            if (error) throw error

            this.profile = data

            // Update cache
            localStorage.setItem(CACHE_KEY, JSON.stringify({
                data,
                timestamp: Date.now(),
                userId: this.session.user.id
            }))

            return data
        } catch (err) {
            this.error = err.message
            return null
        } finally {
            this.loading = false
        }
    },

    async init() {
        this.loading = true
        const { data: { session } } = await supabase.auth.getSession()
        this.session = session

        if (session) {
            await this.fetchProfile()
        }

        supabase.auth.onAuthStateChange(async (event, session) => {
            this.session = session
            if (session) {
                await this.fetchProfile()
            } else {
                this.profile = null
                localStorage.removeItem(CACHE_KEY)
            }
        })
    },

    clearCache() {
        this.profile = null
        localStorage.removeItem(CACHE_KEY)
    }
})

// Initialize immediately
authStore.init()
