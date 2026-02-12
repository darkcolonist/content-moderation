-- Final Robust Migration to fix "Database error saving new user"
-- This version is designed to be extremely resilient to schema/extension issues.

-- 1. Ensure extensions schema exists (standard in Supabase)
CREATE SCHEMA IF NOT EXISTS extensions;

-- 2. Try to enable pgcrypto in the extensions schema
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- 3. Cleanup all previous attempts
DROP TRIGGER IF EXISTS tr_create_default_api_key ON public.profiles;
DROP FUNCTION IF EXISTS public.handle_new_user_api_key();
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 4. Re-create the master handle_new_user function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_tokens INTEGER;
    v_provider TEXT;
    v_random_key TEXT;
BEGIN
    -- A. Determine provider and tokens
    v_provider := COALESCE(NEW.raw_app_meta_data->>'provider', 'email');
    v_tokens := CASE WHEN v_provider = 'google' THEN 3 ELSE 0 END;

    -- B. Create the Profile (This is the most critical part)
    INSERT INTO public.profiles (id, email, role, tokens, is_blocked)
    VALUES (NEW.id, NEW.email, 'user', v_tokens, FALSE)
    ON CONFLICT (id) DO UPDATE 
    SET email = EXCLUDED.email; -- Handle rare cases where profile exists

    -- C. Create the Default API Key (Wrapped in a sub-block to prevent signup failure)
    BEGIN
        -- Generate random key: try pgcrypto first, fallback to simpler md5 if it fails
        v_random_key := 'sk_live_' || 
            encode(CASE 
                WHEN current_setting('search_path') LIKE '%extensions%' THEN extensions.gen_random_bytes(24)
                ELSE gen_random_bytes(24) 
            END, 'hex');
    EXCEPTION WHEN OTHERS THEN
        -- Ultimate fallback if extensions/pgcrypto is missing
        v_random_key := 'sk_live_' || md5(NEW.id::text || clock_timestamp()::text || random()::text);
    END;

    -- D. Insert the key (ignore failures here to ensure signup doesn't break)
    BEGIN
        INSERT INTO public.api_keys (user_id, api_key, name)
        VALUES (NEW.id, v_random_key, 'default');
    EXCEPTION WHEN OTHERS THEN
        -- If it fails, we keep going so the user can still log in
        NULL;
    END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Re-attach trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

