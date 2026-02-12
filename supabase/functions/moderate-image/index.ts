import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const PICPURIFY_API_URL = "https://www.picpurify.com/analyse/1.1"

serve(async (req: Request) => {
  const allowedOriginsRaw = Deno.env.get('ALLOWED_ORIGINS') || 'http://localhost:5173,http://127.0.0.1:5173'
  const ALLOWED_ORIGINS = allowedOriginsRaw.split(',').map(o => o.trim())

  const origin = req.headers.get('Origin')
  const isAllowedOrigin = origin && ALLOWED_ORIGINS.includes(origin)

  const corsHeaders = {
    'Access-Control-Allow-Origin': isAllowedOrigin ? origin : ALLOWED_ORIGINS[0],
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-api-key',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Max-Age': '86400',
  }

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Optional: Strictly block unauthorized origins for non-OPTIONS requests
  if (origin && !isAllowedOrigin) {
    return new Response(JSON.stringify({ error: 'Origin not allowed' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 403,
    })
  }

  try {
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    const PICPURIFY_API_KEY = Deno.env.get('PICPURIFY_API_KEY')

    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY || !PICPURIFY_API_KEY) {
      throw new Error('Missing environment variables')
    }

    // 1. Get request body early to check imageUrl
    const body = await req.json().catch(() => ({}))
    const { imageUrl, tasks } = body

    if (!imageUrl) {
      return new Response(JSON.stringify({ error: 'imageUrl is required' }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      })
    }

    // 2. Get API key from headers
    const apiKey = req.headers.get('x-api-key') || req.headers.get('Authorization')?.replace('Bearer ', '')

    if (!apiKey) {
      return new Response(JSON.stringify({ error: 'Missing API key' }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 401,
      })
    }

    // 3. Initialize Supabase
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // 4. Verify API key, check rate limit and tokens (Initial check)
    const { data: verifyData, error: verifyError } = await supabase.rpc('verify_api_key', {
      p_api_key: apiKey
    })

    if (verifyError) throw verifyError
    
    const verification = verifyData[0]

    if (!verification.success) {
      return new Response(JSON.stringify({ error: verification.error_message }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 403,
      })
    }

    const { user_id: userId } = verification

    // 5. Prepare PicPurify request
    const formData = new FormData()
    formData.append('API_KEY', PICPURIFY_API_KEY)
    formData.append('task', tasks || 'porn_moderation,suggestive_nudity_moderation,gore_moderation,drug_moderation,weapon_moderation')
    formData.append('url_image', imageUrl)

    const response = await fetch(PICPURIFY_API_URL, {
      method: 'POST',
      body: formData
    })

    if (!response.ok) {
        throw new Error(`PicPurify API error: ${response.statusText}`)
    }

    const result = await response.json()

    // 6. If PicPurify was successful (moderation result returned), deduct token
    if (result.status === 'success') {
      const { error: deductError } = await supabase.rpc('deduct_user_token', {
        p_user_id: userId
      })
      if (deductError) console.error('Token deduction error:', deductError)
    }

    // 7. Log to Moderation History
    const { error: dbError } = await supabase.from('moderation_history').insert({
      user_id: userId,
      media_id: result.media?.media_id,
      status: result.status,
      final_decision: result.final_decision,
      confidence_score: result.confidence_score_decision || 0,
      task_call: result.task_call,
      image_url: imageUrl,
      raw_response: result
    })

    if (dbError) console.error('Database logging error:', dbError)

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    })

  } catch (error: any) {
    console.error('Edge Function Error:', error)
    return new Response(JSON.stringify({ error: error.message || 'Internal Server Error' }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    })
  }
})
