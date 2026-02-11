-- Alter profiles table to add tokens column
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS tokens INTEGER DEFAULT 0;

-- Update the handle_new_user function to include tokens (if needed for future reference)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role, tokens)
  VALUES (new.id, new.email, 'user', 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
