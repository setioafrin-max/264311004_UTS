-- 0. Bersihkan sisa percobaan sebelumnya (aman dijalankan walau kosong)
DELETE FROM notifikasi_hama WHERE id_notifikasi IN (1,2,3);
DELETE FROM hama WHERE id_hama IN (1,2,3);

-- 1. HAMA
INSERT INTO hama (id_hama, nama_hama, gejala) VALUES
(1, 'Wereng Coklat',   'Daun menguning dan mengering seperti terbakar (hopperburn)'),
(2, 'Penggerek Batang','Pucuk tanaman mati (sundep) dan malai hampa (beluk)'),
(3, 'Tikus Sawah',     'Batang padi terpotong miring dan rumpun rebah');

-- 2. LAHAN (id 1 sudah ada di database, jadi mulai dari 2)
INSERT INTO lahan (id_lahan, id_petani, nama_lahan, lokasi, luas_m2, komoditas) VALUES
(2, 1, 'Lahan Jagung B', 'Madiun',  3200.50, 'Jagung'),
(3, 1, 'Lahan Padi C',   'Magetan', 4500.00, 'Padi'),
(4, 1, 'Lahan Padi D',   'Ngawi',   4000.00, 'Padi');

-- 3. NOTIFIKASI_HAMA
INSERT INTO notifikasi_hama (id_notifikasi, id_lahan, id_hama, pesan, waktu_kirim, status_baca) VALUES
(1, 2, 1, 'Terdeteksi serangan Wereng Coklat di Lahan Jagung B', '2026-10-20 07:30:00', 0),
(2, 3, 2, 'Waspada Penggerek Batang di Lahan Padi C',            '2026-10-21 08:15:00', 0),
(3, 4, 3, 'Ditemukan tanda serangan Tikus Sawah di Lahan Padi D','2026-10-22 06:45:00', 0);
-- menampilkan
SELECT * FROM hama;
--mengubah data
UPDATE notifikasi_hama
SET status_baca = 1
WHERE id_notifikasi = 2;
-- menampilkan
SELECT id_notifikasi, status_baca FROM notifikasi_hama WHERE id_notifikasi = 2;
-- hapus
DELETE FROM notifikasi_hama
WHERE id_notifikasi = 3;
-- menampilkan
SELECT * FROM notifikasi_hama;
