-- Create a storage bucket for moderated images
-- This allows users to upload images directly to Supabase for moderation.

INSERT INTO storage.buckets (id, name, public)
VALUES ('moderated-images', 'moderated-images', true)
ON CONFLICT (id) DO NOTHING;

-- RLS for Storage
-- Allow anyone to read images (if the bucket is public)
-- Allow authenticated users to upload their own images
CREATE POLICY "Public Read Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'moderated-images');

CREATE POLICY "Users can upload their own images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'moderated-images' 
    AND (auth.uid() = owner OR auth.uid()::text = (storage.foldername(name))[1])
);

-- Automated Storage Cleanup Function
-- This function deletes objects in storage that are older than 30 days.
CREATE OR REPLACE FUNCTION public.delete_old_storage_objects()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    DELETE FROM storage.objects
    WHERE bucket_id = 'moderated-images'
    AND created_at < (NOW() - INTERVAL '30 days');
END;
$$;

-- You can also combine this with the moderation_history cleanup
-- or schedule it separately.
