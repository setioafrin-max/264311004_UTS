SELECT
    l.nama_lahan,
    COUNT(n.id_notifikasi) AS jumlah_notifikasi,
    SUM(n.status_baca = 0) AS notifikasi_belum_dibaca
FROM lahan AS l
JOIN notifikasi_hama AS n
    ON l.id_lahan = n.id_lahan
WHERE n.waktu_kirim >= '2026-10-20 00:00:00'
  AND n.waktu_kirim < '2026-10-23 00:00:00'
GROUP BY l.id_lahan, l.nama_lahan;
