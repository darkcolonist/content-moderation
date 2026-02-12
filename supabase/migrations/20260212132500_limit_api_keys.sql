-- Trigger function to limit API keys to 5 per user
CREATE OR REPLACE FUNCTION public.check_api_key_limit()
RETURNS TRIGGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT count(*) INTO v_count
    FROM public.api_keys
    WHERE user_id = NEW.user_id;

    IF v_count >= 5 THEN
        RAISE EXCEPTION 'Maximum limit of 5 API keys reached per user.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on api_keys table
DROP TRIGGER IF EXISTS tr_limit_api_keys ON public.api_keys;
CREATE TRIGGER tr_limit_api_keys
BEFORE INSERT ON public.api_keys
FOR EACH ROW
EXECUTE FUNCTION public.check_api_key_limit();
