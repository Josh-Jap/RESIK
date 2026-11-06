-- ===================================================
-- Seed Data for RESIK (Waste Management System)
-- Compatible with PostgreSQL & Supabase
-- ===================================================

-- 1. Insert Housing Data
INSERT INTO "Housing" (id_house, name_house, address, house_code, house_num, block)
VALUES 
    (1, 'Griya Asri Permai', 'Jl. Bougenville No. 12, Kel. Asri', 102030, 100, 'A1-Z9'),
    (2, 'Taman Hijau Indah', 'Jl. Flamboyan Blok B2 No. 4', 405060, 50, 'B1-B5')
ON CONFLICT (id_house) DO NOTHING;

-- Reset Housing sequence if needed
SELECT setval(pg_get_serial_sequence('"Housing"', 'id_house'), coalesce(max(id_house), 1)) FROM "Housing";

-- 2. Insert User Data (Admin, Petugas, Warga)
INSERT INTO "User" (id_users, name_users, phone_num, email, role, password, id_house)
VALUES
    -- Admin
    (1, 'Rian Hidayat', 081244556677, 'admin@resik.id', 'admin', 'admin123', 1),

    -- Petugas
    (2, 'Budi Santoso', 081234567890, 'petugas@resik.id', 'petugas', 'petugas123', 1),
    (3, 'Siti Aminah', 081398765432, 'siti.petugas@resik.id', 'petugas', 'petugas123', 1),
    (4, 'Joko Widodo', 081111112222, 'joko.petugas@resik.id', 'petugas', 'petugas123', 1),

    -- Warga
    (5, 'Adiatma Fajaruddin', 081244556677, 'warga@resik.id', 'warga', 'warga123', 1),
    (6, 'Budi Santoso (Warga)', 081211112222, 'budi.warga@resik.id', 'warga', 'warga123', 1),
    (7, 'Siti Aminah (Warga)', 081222223333, 'siti.warga@resik.id', 'warga', 'warga123', 1),
    (8, 'Agus Setiawan', 081233334444, 'agus@resik.id', 'warga', 'warga123', 1),
    (9, 'Dewi Lestari', 081244445555, 'dewi@resik.id', 'warga', 'warga123', 1),
    (10, 'Rina Wulandari', 081255556666, 'rina@resik.id', 'warga', 'warga123', 1),
    (11, 'Hendra Wijaya', 081266667777, 'hendra@resik.id', 'warga', 'warga123', 1)
ON CONFLICT (id_users) DO NOTHING;

-- Reset User sequence if needed
SELECT setval(pg_get_serial_sequence('"User"', 'id_users'), coalesce(max(id_users), 1)) FROM "User";

-- 3. Insert Payments Data
INSERT INTO "Payments" (id_payments, id_users, qris_reference, paid_at, month, year, amount)
VALUES
    -- Warga (Adiatma) payments for earlier months
    (1, 5, 'QRIS-202601-5', '2026-01-10 09:30:00', 'Januari', 2026, 50000),
    (2, 5, 'QRIS-202602-5', '2026-02-11 10:15:00', 'Februari', 2026, 50000),
    (3, 5, 'QRIS-202603-5', '2026-03-08 14:00:00', 'Maret', 2026, 50000),
    (4, 5, 'QRIS-202604-5', '2026-04-12 11:45:00', 'April', 2026, 50000),
    (5, 5, 'QRIS-202605-5', '2026-05-09 08:20:00', 'Mei', 2026, 50000),
    (6, 5, 'QRIS-202606-5', '2026-06-14 16:30:00', 'Juni', 2026, 50000),
    (7, 5, 'QRIS-202608-5', '2026-08-10 13:10:00', 'Agustus', 2026, 50000),

    -- Payments from residents shown in Admin Payment Screen (October 2026)
    (8, 6, 'QRIS-202610-BS', '2026-10-15 08:30:00', 'Oktober', 2026, 50000),
    (9, 7, 'QRIS-202610-SA', '2026-10-14 09:15:00', 'Oktober', 2026, 50000),
    (10, 9, 'QRIS-202610-DL', '2026-10-12 14:45:00', 'Oktober', 2026, 50000),
    (11, 11, 'QRIS-202610-HW', '2026-10-10 11:20:00', 'Oktober', 2026, 50000)
ON CONFLICT (id_payments) DO NOTHING;

-- Reset Payments sequence if needed
SELECT setval(pg_get_serial_sequence('"Payments"', 'id_payments'), coalesce(max(id_payments), 1)) FROM "Payments";

-- 4. Insert Pickup_req Data
INSERT INTO "Pickup_req" (id_pickup, description, id_users, pickup_date, status, category, photo)
VALUES
    (1, 'Tumpukan sampah plastik dan rumah tangga menumpuk di dekat gerbang Blok B, mengganggu akses jalan.', 5, NOW() - INTERVAL '10 minutes', 'pending', 'Sampah menumpuk', NULL),
    (2, 'Tutup tong sampah umum pecah dan dasar berlubang di area Taman Utama butuh penggantian.', 6, NOW() - INTERVAL '35 minutes', 'in_progress', 'Tong sampah rusak', NULL),
    (3, 'Ranting dan dedaunan pohon peneduh di Jalan Melati telah disapu dan siap diangkut.', 7, NOW() - INTERVAL '1 hour', 'completed', 'Daun berserakan', NULL),
    (4, 'Ada pembuangan sisa material semen di saluran air warga Blok B4 yang menyumbat aliran got.', 8, NOW() - INTERVAL '2 hours', 'pending', 'Limbah liar di selokan', NULL)
ON CONFLICT (id_pickup) DO NOTHING;

-- Reset Pickup_req sequence if needed
SELECT setval(pg_get_serial_sequence('"Pickup_req"', 'id_pickup'), coalesce(max(id_pickup), 1)) FROM "Pickup_req";
