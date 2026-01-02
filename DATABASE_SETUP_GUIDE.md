# Database Setup Guide for Satarknity

This guide will help you set up your Supabase database for the Satarknity application with proper authentication and data storage.

## Prerequisites

1. A Supabase account (sign up at https://supabase.com)
2. A Supabase project created
3. Your project URL and API keys from Supabase dashboard

---

## Step 1: Environment Variables Setup

1. Create a `.env` file in the root of your project (if it doesn't exist)
2. Add the following variables:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

**How to get these values:**
- Go to your Supabase project dashboard
- Navigate to **Settings** → **API**
- Copy the **Project URL** → paste as `VITE_SUPABASE_URL`
- Copy the **anon/public** key → paste as `VITE_SUPABASE_ANON_KEY`

**Important:** Never commit your `.env` file to version control. Add it to `.gitignore`.

---

## Step 2: Database Schema Setup

Run the following SQL in your Supabase SQL Editor (Dashboard → SQL Editor):

### 2.1 Create the Main Incidents Table

```sql
-- Create the satarknity_incidents table
CREATE TABLE IF NOT EXISTS public.satarknity_incidents (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    location TEXT,
    media_urls TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_satarknity_incidents_user_id ON public.satarknity_incidents(user_id);
CREATE INDEX IF NOT EXISTS idx_satarknity_incidents_created_at ON public.satarknity_incidents(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.satarknity_incidents ENABLE ROW LEVEL SECURITY;
```

### 2.2 Row Level Security (RLS) Policies

```sql
-- Policy: Users can view all incidents (public read)
CREATE POLICY "Anyone can view incidents"
    ON public.satarknity_incidents
    FOR SELECT
    USING (true);

-- Policy: Authenticated users can insert their own incidents
CREATE POLICY "Users can insert their own incidents"
    ON public.satarknity_incidents
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own incidents
CREATE POLICY "Users can update their own incidents"
    ON public.satarknity_incidents
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own incidents
CREATE POLICY "Users can delete their own incidents"
    ON public.satarknity_incidents
    FOR DELETE
    USING (auth.uid() = user_id);
```

### 2.3 Optional: Other Tables (if needed for future features)

```sql
-- Trusted Contacts Table
CREATE TABLE IF NOT EXISTS public.trusted_contacts (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.trusted_contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own contacts"
    ON public.trusted_contacts
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Location History Table
CREATE TABLE IF NOT EXISTS public.location_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION,
    speed DOUBLE PRECISION,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.location_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own location history"
    ON public.location_history
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Location Shares Table
CREATE TABLE IF NOT EXISTS public.location_shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    is_sharing BOOLEAN DEFAULT true,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.location_shares ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own location shares"
    ON public.location_shares
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Route Shares Table
CREATE TABLE IF NOT EXISTS public.route_shares (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    destination TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT true
);

ALTER TABLE public.route_shares ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own route shares"
    ON public.route_shares
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
```

---

## Step 3: Storage Bucket Setup

### 3.1 Create Storage Bucket

1. Go to **Storage** in your Supabase dashboard
2. Click **New bucket**
3. Name: `incidentmedia`
4. **Public bucket**: ✅ Enable (so images/videos can be accessed via URL)
5. Click **Create bucket**

### 3.2 Storage Policies

Go to **Storage** → **Policies** → Select `incidentmedia` bucket, then run:

```sql
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
```

**Note:** The file path structure is `{user_id}/{filename}`, which is why we check `(storage.foldername(name))[1]` to match the user_id.

---

## Step 4: Authentication Setup

### 4.1 Enable Email Authentication

1. Go to **Authentication** → **Providers** in Supabase dashboard
2. Ensure **Email** provider is enabled
3. Configure email templates if needed (optional)

### 4.2 Email Confirmation (Optional)

- **For development**: You can disable email confirmation in **Authentication** → **Settings** → **Email Auth**
- **For production**: Keep email confirmation enabled for security

### 4.3 Password Requirements

Default Supabase password requirements:
- Minimum 6 characters
- Can be customized in **Authentication** → **Settings** → **Password**

---

## Step 5: Verify Setup

### 5.1 Test Database Connection

1. Start your development server:
   ```bash
   npm run dev
   ```

2. Try to sign up a new user
3. Check if the user appears in **Authentication** → **Users** in Supabase dashboard

### 5.2 Test Data Storage

1. Sign in with a test account
2. Submit an incident report with media
3. Verify:
   - Incident appears in `satarknity_incidents` table (Database → Table Editor)
   - Media files appear in Storage → `incidentmedia` bucket
   - Incidents are visible in the app

### 5.3 Test RLS Policies

1. Sign in as User A, create an incident
2. Sign out and sign in as User B
3. Verify User B can see User A's incidents (public read policy)
4. Verify User B cannot update/delete User A's incidents

---

## Step 6: Troubleshooting

### Common Issues

**Issue: "relation does not exist"**
- Solution: Make sure you ran all SQL migrations in Step 2

**Issue: "permission denied for table"**
- Solution: Check RLS policies are created correctly (Step 2.2)

**Issue: "Storage upload fails"**
- Solution: 
  - Verify storage bucket exists and is public
  - Check storage policies are set (Step 3.2)
  - Verify file path structure matches `{user_id}/{filename}`

**Issue: "Invalid API key"**
- Solution: 
  - Double-check `.env` file has correct values
  - Restart your dev server after changing `.env`
  - Verify you're using the **anon** key, not the **service_role** key

**Issue: "Email confirmation required"**
- Solution: 
  - For development: Disable email confirmation in Supabase settings
  - For production: Check your email (including spam folder)

---

## Step 7: Production Checklist

Before deploying to production:

- [ ] Enable email confirmation
- [ ] Set up custom email templates
- [ ] Configure CORS settings if needed
- [ ] Set up database backups
- [ ] Review and tighten RLS policies if needed
- [ ] Set up monitoring/alerts
- [ ] Use environment-specific `.env` files
- [ ] Enable rate limiting (Supabase handles this automatically)
- [ ] Review storage bucket size limits

---

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)

---

## Quick Reference: Table Schema

### `satarknity_incidents`
- `id` (BIGSERIAL) - Primary key
- `user_id` (UUID) - Foreign key to auth.users
- `description` (TEXT) - Incident description
- `location` (TEXT) - Location string
- `media_urls` (TEXT[]) - Array of media file URLs
- `created_at` (TIMESTAMPTZ) - Auto-generated timestamp

### Storage: `incidentmedia` bucket
- File structure: `{user_id}/{random_filename}.{ext}`
- Public access enabled
- Supports images and videos

---

**Setup Complete!** Your database is now ready for authentication and data storage. 🎉

