-- ===================================================
-- RESIK: Reset Database untuk Simulasi Baru
-- ===================================================

-- 1. Kosongkan tabel transaksi
TRUNCATE TABLE "Pickup_req", "Payments" CASCADE;

-- 2. Hapus semua user selain Admin
DELETE FROM "User" WHERE role != 'admin';

-- 3. Pastikan Akun Default Admin tersedia
INSERT INTO "User" (name_users, phone_num, email, role, password, id_house)
VALUES ('Admin RESIK', 081244556677, 'admin@resik.id', 'admin', 'admin123', 1)
ON CONFLICT (email) DO UPDATE 
SET password = 'admin123', role = 'admin', name_users = 'Admin RESIK';

-- 4. Reset sequence ID
SELECT setval(pg_get_serial_sequence('"Pickup_req"', 'id_pickup'), 1, false);
SELECT setval(pg_get_serial_sequence('"Payments"', 'id_payments'), 1, false);

-- 5. Nonaktifkan RLS agar dapat diakses oleh anon client Flutter
ALTER TABLE "Housing" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "User" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "Payments" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "Pickup_req" DISABLE ROW LEVEL SECURITY;
