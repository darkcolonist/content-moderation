-- Update deduct_user_token to accept an amount
CREATE OR REPLACE FUNCTION public.deduct_user_token(p_user_id UUID, p_amount INTEGER DEFAULT 1)
RETURNS VOID AS $$
BEGIN
    UPDATE public.profiles
    SET tokens = tokens - p_amount
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
