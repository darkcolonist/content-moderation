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

## 2. Prepare the Edge Function
The function code is located in `supabase/functions/moderate-image/index.ts`.

If you are using the **Supabase CLI**, you can skip step 3 and go straight to **Deployment**.

## 3. Manual Setup (Dashboard)
If you prefer not to use the CLI:
1. In the **Edge Functions** section, click **New Function**.
2. Name it `moderate-image`.
3. Copy the contents of `supabase/functions/moderate-image/index.ts` and paste it into the editor.

## 4. Deployment
If you are using the Supabase CLI, you would run:
`supabase functions deploy moderate-image`

Since you are using the dashboard, just click **Save** or **Deploy** in the dashboard editor.

## 5. Database Table & Security
1. Run the migration `supabase/migrations/20260212114600_create_api_keys.sql` in your **SQL Editor**. This creates the `api_keys` table and the `verify_api_key` / `deduct_user_token` functions.
2. Make sure you have the `moderation_history` table created from previous migrations.

## 6. Authentication
The edge function now uses API keys for authentication.
- Header: `x-api-key: your_api_key`
- Or: `Authorization: Bearer your_api_key`

A user must have:
1. A valid API key in the `api_keys` table.
2. At least 1 token in their `profiles.tokens` column.
3. Not exceeded the rate limit (1 call per 5 seconds).

## 7. Testing the Function

### Option A: Using cURL
Replace `[PROJECT_REF]` and `[USER_API_KEY]` with your actual values.

```bash
curl -i -X POST "https://[PROJECT_REF].supabase.co/functions/v1/moderate-image" \
  -H "x-api-key: [USER_API_KEY]" \
  -H "Content-Type: application/json" \
  -d '{
    "imageUrl": "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
    "tasks": "porn_moderation,gore_moderation"
  }'
```

### Option B: Using Postman
1. **Method**: Set to `POST`.
2. **URL**: `https://[PROJECT_REF].supabase.co/functions/v1/moderate-image`
3. **Headers**:
   - `Content-Type`: `application/json`
   - `x-api-key`: `YOUR_API_KEY` (Generate this in the Dashboard -> API Keys section)
4. **Body**: Select `raw` and `JSON` format.
   ```json
   {
     "imageUrl": "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
     "tasks": "porn_moderation,suggestive_nudity_moderation,gore_moderation"
   }
   ```
5. **Click Send**.

### Common Response Statuses
- `200 OK`: Success! Check `final_decision` (OK/KO).
- `401 Unauthorized`: API key is missing.
- `403 Forbidden`: API key is invalid, user is out of tokens, or rate limit exceeded.
- `400 Bad Request`: Missing `imageUrl` or other input error.
