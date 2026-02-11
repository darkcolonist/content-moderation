-- Create the moderation_history table
CREATE TABLE IF NOT EXISTS public.moderation_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    media_id TEXT,
    status TEXT, -- 'success' or 'failure'
    final_decision TEXT, -- 'OK' or 'KO'
    confidence_score FLOAT,
    task_call TEXT,
    image_url TEXT,
    raw_response JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.moderation_history ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
-- Users can view their own moderation history
DROP POLICY IF EXISTS "Users can view own moderation history" ON public.moderation_history;
CREATE POLICY "Users can view own moderation history" 
ON public.moderation_history FOR SELECT 
USING (auth.uid() = user_id);

-- Admins can view ALL moderation history
DROP POLICY IF EXISTS "Admins can view all moderation history" ON public.moderation_history;
CREATE POLICY "Admins can view all moderation history" 
ON public.moderation_history FOR SELECT 
USING (public.is_admin());

-- Allow the authenticated users to insert their own records
-- (Though Edge Functions will typically use service_role to insert on behalf of users)
DROP POLICY IF EXISTS "Users can insert own moderation history" ON public.moderation_history;
CREATE POLICY "Users can insert own moderation history" 
ON public.moderation_history FOR INSERT 
WITH CHECK (auth.uid() = user_id);
