-- Migration to ensure all existing users have a 'default' API key
-- and to rename any 'Default Key' to 'default'

-- 1. Rename existing 'Default Key' to 'default'
UPDATE public.api_keys
SET name = 'default'
WHERE name = 'Default Key';

-- 2. Create a 'default' API key for users who don't have ANY API keys
DO $$
DECLARE
    r RECORD;
    v_random_key TEXT;
BEGIN
    FOR r IN 
        SELECT p.id 
        FROM public.profiles p
        LEFT JOIN public.api_keys ak ON p.id = ak.user_id
        WHERE ak.id IS NULL
    LOOP
        -- Generate a random key prefixed with sk_live_
        v_random_key := 'sk_live_' || encode(gen_random_bytes(24), 'hex');

        INSERT INTO public.api_keys (user_id, api_key, name)
        VALUES (r.id, v_random_key, 'default');
    END LOOP;
END;
$$;
