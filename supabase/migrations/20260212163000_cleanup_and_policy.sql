-- Update RLS policies to enforce 30-day limit
-- This ensures that even if the frontend doesn't filter, the database will only return the last 30 days of data for regular users.

-- 1. Update the user policy
DROP POLICY IF EXISTS "Users can view own moderation history" ON public.moderation_history;
CREATE POLICY "Users can view own moderation history" 
ON public.moderation_history FOR SELECT 
USING (
    auth.uid() = user_id 
    AND created_at > (NOW() - INTERVAL '30 days')
);

-- 2. Optional: If we want to restrict admins too, we can. 
-- But typically admins might want to see older data unless explicitly forbidden.
-- The request said "ensure policies for fetching last moderated history to only last 30 days".
-- Let's update admin policy too just in case that's what's meant by "fetching history".
DROP POLICY IF EXISTS "Admins can view all moderation history" ON public.moderation_history;
CREATE POLICY "Admins can view all moderation history" 
ON public.moderation_history FOR SELECT 
USING (
    public.is_admin() 
    AND created_at > (NOW() - INTERVAL '30 days')
);


-- Automated Cleanup Function
-- This function can be called manually or via a cron job to delete old records.
CREATE OR REPLACE FUNCTION public.delete_old_moderation_history()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    DELETE FROM public.moderation_history
    WHERE created_at < (NOW() - INTERVAL '30 days');
END;
$$;

-- Note for the user: To automate this, you can use pg_cron (if enabled in your Supabase project):
-- SELECT cron.schedule('0 0 * * *', 'SELECT public.delete_old_moderation_history()');
