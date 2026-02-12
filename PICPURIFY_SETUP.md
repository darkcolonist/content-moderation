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

## 5. Database Table
Make sure you have run the migration I provided to create the `moderation_history` table. You can do this in the **SQL Editor** of your Supabase dashboard.
