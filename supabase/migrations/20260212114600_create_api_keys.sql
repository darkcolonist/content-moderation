-- Create api_keys table
CREATE TABLE IF NOT EXISTS public.api_keys (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    api_key TEXT NOT NULL UNIQUE,
    name TEXT,
    last_used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.api_keys ENABLE ROW LEVEL SECURITY;

-- Policies
DROP POLICY IF EXISTS "Users can view their own API keys" ON public.api_keys;
CREATE POLICY "Users can view their own API keys"
ON public.api_keys FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own API keys" ON public.api_keys;
CREATE POLICY "Users can delete their own API keys"
ON public.api_keys FOR DELETE
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own API keys" ON public.api_keys;
CREATE POLICY "Users can create their own API keys"
ON public.api_keys FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view all API keys" ON public.api_keys;
CREATE POLICY "Admins can view all API keys"
ON public.api_keys FOR SELECT
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete any API key" ON public.api_keys;
CREATE POLICY "Admins can delete any API key"
ON public.api_keys FOR DELETE
USING (public.is_admin());

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_api_keys_hash ON public.api_keys(api_key);

-- Function to verify API key and check rate limit/tokens
CREATE OR REPLACE FUNCTION public.verify_api_key(p_api_key TEXT)
RETURNS TABLE (
    success BOOLEAN,
    user_id UUID,
    error_message TEXT
) AS $$
DECLARE
    v_user_id UUID;
    v_tokens INTEGER;
    v_last_used TIMESTAMP WITH TIME ZONE;
    v_rate_limit_seconds INTEGER := 5;
BEGIN
    -- Get API key details
    SELECT ak.user_id, ak.last_used_at, p.tokens
    INTO v_user_id, v_last_used, v_tokens
    FROM public.api_keys ak
    JOIN public.profiles p ON ak.user_id = p.id
    WHERE ak.api_key = p_api_key;

    -- Check if key exists
    IF v_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Invalid API key'::TEXT;
        RETURN;
    END IF;

    -- Check rate limit
    IF v_last_used IS NOT NULL AND (now() - v_last_used) < (v_rate_limit_seconds || ' seconds')::INTERVAL THEN
        RETURN QUERY SELECT FALSE, v_user_id, 'Rate limit exceeded. Please wait 5 seconds.'::TEXT;
        RETURN;
    END IF;

    -- Check tokens (Initial check)
    IF v_tokens <= 0 THEN
        RETURN QUERY SELECT FALSE, v_user_id, 'Insufficient tokens'::TEXT;
        RETURN;
    END IF;

    -- Update last_used_at immediately to reserve the rate limit slot
    UPDATE public.api_keys
    SET last_used_at = now()
    WHERE api_key = p_api_key;

    RETURN QUERY SELECT TRUE, v_user_id, NULL::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to deduct token after successful moderation
CREATE OR REPLACE FUNCTION public.deduct_user_token(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.profiles
    SET tokens = tokens - 1
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
