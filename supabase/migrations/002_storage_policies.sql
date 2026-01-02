-- Storage Policies for incidentmedia bucket
-- Run this AFTER creating the storage bucket in Supabase Dashboard
-- Storage → New bucket → Name: "incidentmedia" → Public: enabled

-- Policy: Anyone can view files (public read)
CREATE POLICY "Public can view incident media"
    ON storage.objects
    FOR SELECT
    USING (bucket_id = 'incidentmedia');

-- Policy: Authenticated users can upload files
CREATE POLICY "Authenticated users can upload incident media"
    ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'incidentmedia' 
        AND auth.role() = 'authenticated'
    );

-- Policy: Users can update their own files
CREATE POLICY "Users can update their own incident media"
    ON storage.objects
    FOR UPDATE
    USING (
        bucket_id = 'incidentmedia' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    )
    WITH CHECK (
        bucket_id = 'incidentmedia' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Policy: Users can delete their own files
CREATE POLICY "Users can delete their own incident media"
    ON storage.objects
    FOR DELETE
    USING (
        bucket_id = 'incidentmedia' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

