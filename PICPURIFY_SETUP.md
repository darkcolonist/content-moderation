# PicPurify Supabase Edge Function Setup Guide

This guide will walk you through setting up the PicPurify moderation logic using Supabase Edge Functions via the dashboard.

## 1. Set Up Environment Variables (Secrets)
Before creating the function, you need to add your API keys to Supabase Secrets.
1. Go to your **Supabase Dashboard**.
2. Navigate to **Edge Functions** (in the sidebar).
3. Click on the **Manage Secrets** (or similar settings icon).
4. Add the following secret:
   - `PICPURIFY_API_KEY`: Your API key from [PicPurify](https://www.picpurify.com/dashboard.html).

*Note: `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are usually provided by default in the environment.*

## 2. Create the Edge Function
1. In the **Edge Functions** section, click **New Function**.
2. Name it `moderate-image`.
3. Paste the following code into the editor:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const PICPURIFY_API_URL = "https://www.picpurify.com/analyse/1.1"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { imageUrl, tasks, userId } = await req.json()
    
    const PICPURIFY_API_KEY = Deno.env.get('PICPURIFY_API_KEY')
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!PICPURIFY_API_KEY) {
      throw new Error('PICPURIFY_API_KEY is not set in Supabase Secrets')
    }

    // 1. Prepare PicPurify request
    const formData = new FormData()
    formData.append('API_KEY', PICPURIFY_API_KEY)
    formData.append('task', tasks || 'porn_moderation,suggestive_nudity_moderation,gore_moderation,drug_moderation,weapon_moderation')
    formData.append('url_image', imageUrl)

    const response = await fetch(PICPURIFY_API_URL, {
      method: 'POST',
      body: formData
    })

    const result = await response.json()

    // 2. Log to Database
    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!)
    
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

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    })
  }
})
```

## 3. Deployment
If you are using the Supabase CLI, you would run:
`supabase functions deploy moderate-image`

Since you are using the dashboard, just click **Save** or **Deploy** in the dashboard editor.

## 4. Database Table
Make sure you have run the migration I provided to create the `moderation_history` table. You can do this in the **SQL Editor** of your Supabase dashboard.
