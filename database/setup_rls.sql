-- =====================================================================
-- SCRIPT PENANGANAN RLS SUPABASE UNTUK PROYEK RESIK
-- Salin dan jalankan seluruh query ini di SQL Editor Dashboard Supabase:
-- Dashboard Supabase -> Project Settings -> SQL Editor -> New Query -> Run
-- =====================================================================

-- OPSI 1 (PALING DIREKOMENDASIKAN UNTUK DEVELOPMENT & SIMULASI):
-- Menonaktifkan Row Level Security agar aplikasi Flutter dapat
-- membaca dan menulis data (SELECT, INSERT, UPDATE, DELETE) tanpa diblokir:

ALTER TABLE "Housing" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "User" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "Payments" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "Pickup_req" DISABLE ROW LEVEL SECURITY;

-- =====================================================================
-- OPSI 2 (JIKA ANDA TETAP INGIN MENGAKTIFKAN RLS DENGAN POLICY RESMI):
-- Aktifkan RLS dan berikan akses penuh untuk role 'anon' dan 'authenticated'
-- =====================================================================

/*
-- 1. Housing Table Policies
ALTER TABLE "Housing" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon full access Housing" ON "Housing";
CREATE POLICY "Allow anon full access Housing" 
ON "Housing" FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- 2. User Table Policies
ALTER TABLE "User" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon full access User" ON "User";
CREATE POLICY "Allow anon full access User" 
ON "User" FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- 3. Payments Table Policies
ALTER TABLE "Payments" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon full access Payments" ON "Payments";
CREATE POLICY "Allow anon full access Payments" 
ON "Payments" FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- 4. Pickup_req Table Policies
ALTER TABLE "Pickup_req" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon full access Pickup_req" ON "Pickup_req";
CREATE POLICY "Allow anon full access Pickup_req" 
ON "Pickup_req" FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
*/
