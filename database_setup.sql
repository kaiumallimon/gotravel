-- ================================================================
-- GoTravel Database Setup Script
-- Run this in your Supabase SQL Editor
-- ================================================================

-- First, let's create the hotels table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.hotels (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  address text,
  city text,
  country text,
  latitude double precision,
  longitude double precision,
  contact_email text,
  phone text,
  rating double precision DEFAULT 0.0,
  reviews_count integer DEFAULT 0,
  cover_image text,
  images text[], -- Array of image URLs
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT hotels_pkey PRIMARY KEY (id)
);

-- Create the rooms table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.rooms (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  hotel_id uuid NOT NULL,
  room_type text NOT NULL,
  price_per_night double precision NOT NULL,
  currency text DEFAULT 'USD'::text,
  capacity integer NOT NULL,
  bed_type text,
  amenities text[], -- Array of amenities
  available_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT rooms_pkey PRIMARY KEY (id),
  CONSTRAINT rooms_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
);

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
DROP TRIGGER IF EXISTS update_hotels_updated_at ON hotels;
CREATE TRIGGER update_hotels_updated_at 
  BEFORE UPDATE ON hotels 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_rooms_updated_at ON rooms;
CREATE TRIGGER update_rooms_updated_at 
  BEFORE UPDATE ON rooms 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- ================================================================
-- Row Level Security Setup
-- ================================================================

-- Enable RLS on hotels table
ALTER TABLE hotels ENABLE ROW LEVEL SECURITY;

-- Enable RLS on rooms table  
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins can do everything on hotels" ON hotels;
DROP POLICY IF EXISTS "Public can read hotels" ON hotels;
DROP POLICY IF EXISTS "Admins can do everything on rooms" ON rooms;
DROP POLICY IF EXISTS "Public can read rooms" ON rooms;

-- ================================================================
-- Hotels Table Policies
-- ================================================================

-- Policy for admins to do everything (SELECT, INSERT, UPDATE, DELETE) on hotels
CREATE POLICY "Admins can do everything on hotels" ON hotels
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
);

-- Policy for public to read hotels (both authenticated and anonymous users)
CREATE POLICY "Public can read hotels" ON hotels
FOR SELECT 
TO anon, authenticated
USING (true);

-- ================================================================
-- Rooms Table Policies  
-- ================================================================

-- Policy for admins to do everything on rooms
CREATE POLICY "Admins can do everything on rooms" ON rooms
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
);

-- Policy for public to read rooms
CREATE POLICY "Public can read rooms" ON rooms
FOR SELECT 
TO anon, authenticated
USING (true);

-- ================================================================
-- Storage Bucket Setup (for images)
-- ================================================================

-- Create storage bucket for images if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('cdn', 'cdn', true)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies
DROP POLICY IF EXISTS "Admins can upload images" ON storage.objects;
DROP POLICY IF EXISTS "Admins can manage images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can upload images" ON storage.objects;

-- Simple policy: Allow authenticated admins to do everything with images
CREATE POLICY "Admins can manage images" ON storage.objects
FOR ALL
TO authenticated
USING (
  bucket_id = 'cdn' 
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
)
WITH CHECK (
  bucket_id = 'cdn' 
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
);

-- Policy for public to view images
CREATE POLICY "Public can view images" ON storage.objects
FOR SELECT 
TO anon, authenticated
USING (bucket_id = 'cdn');

-- Fallback: Allow any authenticated user to upload (for testing)
-- You can remove this after confirming admin policy works
CREATE POLICY "Anyone can upload images" ON storage.objects
FOR INSERT 
TO authenticated
WITH CHECK (bucket_id = 'cdn');

-- ================================================================
-- Test Data (Optional - Remove if not needed)
-- ================================================================

-- Uncomment the following lines if you want to create a test admin user
-- Note: You should create this user through your app's sign-up process instead

-- INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
-- VALUES (
--   gen_random_uuid(),
--   'admin@example.com',
--   crypt('admin123', gen_salt('bf')),
--   now(),
--   now(),
--   now()
-- ) ON CONFLICT (email) DO NOTHING;

-- INSERT INTO public.users (id, email, role, name)
-- SELECT id, email, 'admin', 'Test Admin'
-- FROM auth.users
-- WHERE email = 'admin@example.com'
-- ON CONFLICT (email) DO NOTHING;

-- ================================================================
-- Verification Queries
-- ================================================================

-- Run these queries to verify everything is set up correctly:

-- Check if tables exist
SELECT 
  schemaname,
  tablename 
FROM pg_tables 
WHERE tablename IN ('hotels', 'rooms', 'users') 
  AND schemaname = 'public';

-- Check RLS status
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('hotels', 'rooms') 
  AND schemaname = 'public';

-- Check policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename IN ('hotels', 'rooms');

-- Check storage bucket
SELECT * FROM storage.buckets WHERE id = 'cdn';

COMMIT;