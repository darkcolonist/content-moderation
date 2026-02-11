-- 1. Add is_blocked column to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;

-- 2. Update handle_new_user to include is_blocked
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role, tokens, is_blocked)
  VALUES (new.id, new.email, 'user', 0, FALSE);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Update RLS to allow admins to UPDATE profiles (for blocking and tokens)
DROP POLICY IF EXISTS "Admins can update profiles" ON public.profiles;
CREATE POLICY "Admins can update profiles" 
ON public.profiles FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());
