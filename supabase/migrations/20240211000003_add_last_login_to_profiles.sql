-- Create a function to track last login on the profile table
CREATE OR REPLACE FUNCTION public.handle_login()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.profiles
  SET updated_at = NOW()
  WHERE id = new.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Note: In a real-world scenario, you might want a separate last_login column
-- But we can use updated_at or add a specific column if needed.
-- Let's add a specific last_login column to make it explicitly clear.

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;

-- Refined login handler
CREATE OR REPLACE FUNCTION public.handle_login()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.profiles
  SET last_login = NOW(),
      updated_at = NOW()
  WHERE id = new.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- We can't easily trigger off auth.sessions or auth.users sign_in from within Supabase SQL accurately for every login type without extra setup.
-- However, we can update it from the frontend when the user first loads the app with a session.
