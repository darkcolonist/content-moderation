-- Update the handle_new_user function to grant 3 tokens to Gmail OAuth users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_tokens INTEGER;
    v_provider TEXT;
BEGIN
    -- Check if the user signed up via Google OAuth
    -- We check the raw_app_meta_data for the provider information
    v_provider := NEW.raw_app_meta_data->>'provider';
    
    -- If provider is 'google', grant 3 tokens, otherwise 0
    IF v_provider = 'google' THEN
        v_tokens := 3;
    ELSE
        v_tokens := 0;
    END IF;
    
    INSERT INTO public.profiles (id, email, role, tokens)
    VALUES (NEW.id, NEW.email, 'user', v_tokens);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
