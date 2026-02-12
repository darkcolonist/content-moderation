-- Function to create a default API key for new users
CREATE OR REPLACE FUNCTION public.handle_new_user_api_key()
RETURNS TRIGGER AS $$
DECLARE
    v_random_key TEXT;
BEGIN
    -- Generate a random key prefixed with sk_live_
    v_random_key := 'sk_live_' || encode(gen_random_bytes(24), 'hex');

    INSERT INTO public.api_keys (user_id, api_key, name)
    VALUES (NEW.id, v_random_key, 'Default Key');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function after a new profile is created
DROP TRIGGER IF EXISTS tr_create_default_api_key ON public.profiles;
CREATE TRIGGER tr_create_default_api_key
AFTER INSERT ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user_api_key();
