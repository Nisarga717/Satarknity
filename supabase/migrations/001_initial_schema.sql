-- Satarknity Database Schema Migration
-- Run this in your Supabase SQL Editor

-- ============================================
-- 1. MAIN INCIDENTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.satarknity_incidents (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    location TEXT,
    media_urls TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_satarknity_incidents_user_id 
    ON public.satarknity_incidents(user_id);
CREATE INDEX IF NOT EXISTS idx_satarknity_incidents_created_at 
    ON public.satarknity_incidents(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.satarknity_incidents ENABLE ROW LEVEL SECURITY;

-- RLS Policies for satarknity_incidents
CREATE POLICY "Anyone can view incidents"
    ON public.satarknity_incidents
    FOR SELECT
    USING (true);

CREATE POLICY "Users can insert their own incidents"
    ON public.satarknity_incidents
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own incidents"
    ON public.satarknity_incidents
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own incidents"
    ON public.satarknity_incidents
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- 2. TRUSTED CONTACTS TABLE (Optional)
-- ============================================

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

-- ============================================
-- 3. LOCATION HISTORY TABLE (Optional)
-- ============================================

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

-- ============================================
-- 4. LOCATION SHARES TABLE (Optional)
-- ============================================

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

-- ============================================
-- 5. ROUTE SHARES TABLE (Optional)
-- ============================================

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

