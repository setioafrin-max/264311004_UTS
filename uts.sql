CREATE DATABASE IF NOT EXISTS smart_farming;
USE smart_farming;

CREATE TABLE petani (
    id_petani   INT AUTO_INCREMENT PRIMARY KEY,
    nama_petani VARCHAR(100) NOT NULL
);

CREATE TABLE hama (
    id_hama   INT AUTO_INCREMENT PRIMARY KEY,
    nama_hama VARCHAR(100) NOT NULL,
    gejala    TEXT,
    CONSTRAINT uq_nama_hama UNIQUE (nama_hama)
);

CREATE TABLE lahan (
    id_lahan   INT AUTO_INCREMENT PRIMARY KEY,
    id_petani  INT           NOT NULL,
    nama_lahan VARCHAR(100)  NOT NULL,
    lokasi     VARCHAR(255)  NOT NULL,
    luas_m2    DECIMAL(10,2) NOT NULL,
    komoditas  VARCHAR(100)  NOT NULL,

    CONSTRAINT fk_lahan_petani FOREIGN KEY (id_petani)
        REFERENCES petani (id_petani)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_luas CHECK (luas_m2 > 0)
);

CREATE TABLE sensor_kelembapan (
    id_sensor_kelembapan INT AUTO_INCREMENT PRIMARY KEY,
    id_lahan             INT NOT NULL,
    satuan               VARCHAR(20) NOT NULL DEFAULT '%',
    status_sensor        ENUM('AKTIF','NONAKTIF','RUSAK') NOT NULL DEFAULT 'AKTIF',

    CONSTRAINT fk_sensor_kelembapan_lahan FOREIGN KEY (id_lahan)
        REFERENCES lahan (id_lahan)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE sensor_cuaca (
    id_sensor_cuaca INT AUTO_INCREMENT PRIMARY KEY,
    id_lahan        INT NOT NULL,
    status_sensor   ENUM('AKTIF','NONAKTIF','RUSAK') NOT NULL DEFAULT 'AKTIF',

    CONSTRAINT fk_sensor_cuaca_lahan FOREIGN KEY (id_lahan)
        REFERENCES lahan (id_lahan)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE sensor_hama (
    id_sensor_hama INT AUTO_INCREMENT PRIMARY KEY,
    id_lahan       INT NOT NULL,
    status_sensor  ENUM('AKTIF','NONAKTIF','RUSAK') NOT NULL DEFAULT 'AKTIF',

    CONSTRAINT fk_sensor_hama_lahan FOREIGN KEY (id_lahan)
        REFERENCES lahan (id_lahan)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE pembacaan_kelembapan (
    id_pembacaan_kelembapan BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_sensor_kelembapan    INT           NOT NULL,
    nilai_kelembapan        DECIMAL(5,2)  NOT NULL,
    waktu_baca              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pembacaan_sensor_kelembapan FOREIGN KEY (id_sensor_kelembapan)
        REFERENCES sensor_kelembapan (id_sensor_kelembapan)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_nilai_kelembapan CHECK (nilai_kelembapan BETWEEN 0 AND 100)
);

CREATE TABLE data_cuaca (
    id_data_cuaca    BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_sensor_cuaca  INT           NOT NULL,
    suhu             DECIMAL(5,2)  NOT NULL,
    kelembapan_udara DECIMAL(5,2)  NOT NULL,
    curah_hujan      DECIMAL(6,2)  NOT NULL,
    waktu_baca       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_data_cuaca_sensor FOREIGN KEY (id_sensor_cuaca)
        REFERENCES sensor_cuaca (id_sensor_cuaca)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_kelembapan_udara CHECK (kelembapan_udara BETWEEN 0 AND 100),
    CONSTRAINT chk_curah_hujan CHECK (curah_hujan >= 0)
);

CREATE TABLE pembacaan_hama (
    id_pembacaan_hama BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_sensor_hama    INT         NOT NULL,
    tingkat_deteksi   VARCHAR(50) NOT NULL,
    waktu_baca        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pembacaan_sensor_hama FOREIGN KEY (id_sensor_hama)
        REFERENCES sensor_hama (id_sensor_hama)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE notifikasi_kelembapan (
    id_notifikasi_kelembapan INT AUTO_INCREMENT PRIMARY KEY,
    id_pembacaan_kelembapan  BIGINT       NOT NULL,
    pesan                    VARCHAR(255) NOT NULL,
    waktu_kirim              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_baca              TINYINT(1)   NOT NULL DEFAULT 0,

    CONSTRAINT fk_notif_pembacaan_kelembapan FOREIGN KEY (id_pembacaan_kelembapan)
        REFERENCES pembacaan_kelembapan (id_pembacaan_kelembapan)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE notifikasi_cuaca (
    id_notifikasi_cuaca INT AUTO_INCREMENT PRIMARY KEY,
    id_data_cuaca       BIGINT       NOT NULL,
    pesan               VARCHAR(255) NOT NULL,
    waktu_kirim         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_baca         TINYINT(1)   NOT NULL DEFAULT 0,

    CONSTRAINT fk_notif_data_cuaca FOREIGN KEY (id_data_cuaca)
        REFERENCES data_cuaca (id_data_cuaca)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE notifikasi_hama (
    id_notifikasi_hama INT AUTO_INCREMENT PRIMARY KEY,
    id_pembacaan_hama  BIGINT       NOT NULL,
    id_hama            INT          NOT NULL,
    pesan              VARCHAR(255) NOT NULL,
    waktu_kirim        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_baca        TINYINT(1)   NOT NULL DEFAULT 0,

    CONSTRAINT fk_notif_pembacaan_hama FOREIGN KEY (id_pembacaan_hama)
        REFERENCES pembacaan_hama (id_pembacaan_hama)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_notif_hama_master FOREIGN KEY (id_hama)
        REFERENCES hama (id_hama)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_lahan_petani      ON lahan (id_petani);
CREATE INDEX idx_sk_lahan          ON sensor_kelembapan (id_lahan);
CREATE INDEX idx_sc_lahan          ON sensor_cuaca (id_lahan);
CREATE INDEX idx_sh_lahan          ON sensor_hama (id_lahan);
CREATE INDEX idx_pk_waktu          ON pembacaan_kelembapan (id_sensor_kelembapan, waktu_baca);
CREATE INDEX idx_dc_waktu          ON data_cuaca (id_sensor_cuaca, waktu_baca);
CREATE INDEX idx_ph_waktu          ON pembacaan_hama (id_sensor_hama, waktu_baca);
CREATE INDEX idx_nk_pembacaan      ON notifikasi_kelembapan (id_pembacaan_kelembapan);
CREATE INDEX idx_nc_data           ON notifikasi_cuaca (id_data_cuaca);
CREATE INDEX idx_nh_pembacaan      ON notifikasi_hama (id_pembacaan_hama);
CREATE INDEX idx_nh_hama           ON notifikasi_hama (id_hama);

CREATE TRIGGER trg_notif_kelembapan
AFTER INSERT ON pembacaan_kelembapan
FOR EACH ROW
BEGIN
    IF NEW.nilai_kelembapan < 30 THEN
        INSERT INTO notifikasi_kelembapan (id_pembacaan_kelembapan, pesan)
        VALUES (NEW.id_pembacaan_kelembapan,
                CONCAT('Tanah terlalu kering (', NEW.nilai_kelembapan, '%). Segera lakukan penyiraman.'));
    ELSEIF NEW.nilai_kelembapan > 80 THEN
        INSERT INTO notifikasi_kelembapan (id_pembacaan_kelembapan, pesan)
        VALUES (NEW.id_pembacaan_kelembapan,
                CONCAT('Tanah terlalu basah (', NEW.nilai_kelembapan, '%). Periksa drainase lahan.'));
    END IF;
END$$

CREATE TRIGGER trg_notif_cuaca
AFTER INSERT ON data_cuaca
FOR EACH ROW
BEGIN
    IF NEW.suhu > 35 THEN
        INSERT INTO notifikasi_cuaca (id_data_cuaca, pesan)
        VALUES (NEW.id_data_cuaca,
                CONCAT('Suhu ekstrem (', NEW.suhu, ' C). Waspadai tanaman layu.'));
    END IF;
    IF NEW.curah_hujan > 100 THEN
        INSERT INTO notifikasi_cuaca (id_data_cuaca, pesan)
        VALUES (NEW.id_data_cuaca,
                CONCAT('Curah hujan tinggi (', NEW.curah_hujan, ' mm). Waspadai genangan.'));
    END IF;
END$$

DELIMITER ;

INSERT INTO petani (id_petani, nama_petani) VALUES
(1, 'Slamet Riyadi'),
(2, 'Rahayu Lestari');

INSERT INTO lahan (id_lahan, id_petani, nama_lahan, lokasi, luas_m2, komoditas) VALUES
(1, 1, 'Sawah Utara',   'Madiun, Jawa Timur', 5000.00, 'Padi'),
(2, 1, 'Kebun Cabai',   'Madiun, Jawa Timur', 2500.00, 'Cabai'),
(3, 2, 'Ladang Jagung', 'Ngawi, Jawa Timur',  8000.00, 'Jagung');

INSERT INTO hama (id_hama, nama_hama, gejala) VALUES
(1, 'Wereng Coklat', 'Daun menguning dan tanaman mengering seperti terbakar'),
(2, 'Ulat Grayak',   'Daun berlubang dan tinggal tulang daun'),
(3, 'Kutu Daun',     'Daun mengeriting dan muncul embun jelaga');

INSERT INTO sensor_kelembapan (id_sensor_kelembapan, id_lahan, satuan, status_sensor) VALUES
(1, 1, '%', 'AKTIF'),
(2, 2, '%', 'AKTIF'),
(3, 3, '%', 'NONAKTIF');

INSERT INTO sensor_cuaca (id_sensor_cuaca, id_lahan, status_sensor) VALUES
(1, 1, 'AKTIF'),
(2, 3, 'AKTIF');

INSERT INTO sensor_hama (id_sensor_hama, id_lahan, status_sensor) VALUES
(1, 2, 'AKTIF'),
(2, 3, 'RUSAK');

INSERT INTO pembacaan_kelembapan (id_pembacaan_kelembapan, id_sensor_kelembapan, nilai_kelembapan, waktu_baca) VALUES
(1, 1, 65.50, '2026-10-26 06:00:00'),
(2, 2, 22.00, '2026-10-26 06:05:00'),
(3, 1, 85.30, '2026-10-27 06:00:00'),
(4, 2, 55.00, '2026-10-27 06:05:00');

INSERT INTO data_cuaca (id_data_cuaca, id_sensor_cuaca, suhu, kelembapan_udara, curah_hujan, waktu_baca) VALUES
(1, 1, 30.50, 70.00,  10.00, '2026-10-26 12:00:00'),
(2, 2, 37.20, 60.00,   0.00, '2026-10-26 13:00:00'),
(3, 1, 28.00, 90.00, 150.00, '2026-10-27 15:00:00');

INSERT INTO pembacaan_hama (id_pembacaan_hama, id_sensor_hama, tingkat_deteksi, waktu_baca) VALUES
(1, 1, 'TINGGI',  '2026-10-27 07:00:00'),
(2, 1, 'RENDAH',  '2026-10-28 07:00:00');

INSERT INTO notifikasi_hama (id_pembacaan_hama, id_hama, pesan) VALUES
(1, 2, 'Deteksi hama tingkat TINGGI di Kebun Cabai. Lakukan pengendalian segera.');

SELECT * FROM notifikasi_kelembapan;
SELECT * FROM notifikasi_cuaca;

SELECT n.id_notifikasi_kelembapan, pt.nama_petani, l.nama_lahan,
       p.nilai_kelembapan, n.pesan, n.waktu_kirim, n.status_baca
FROM notifikasi_kelembapan n
JOIN pembacaan_kelembapan p ON n.id_pembacaan_kelembapan = p.id_pembacaan_kelembapan
JOIN sensor_kelembapan s    ON p.id_sensor_kelembapan = s.id_sensor_kelembapan
JOIN lahan l                ON s.id_lahan = l.id_lahan
JOIN petani pt              ON l.id_petani = pt.id_petani;

SELECT nh.id_notifikasi_hama, l.nama_lahan, h.nama_hama, h.gejala,
       ph.tingkat_deteksi, nh.pesan
FROM notifikasi_hama nh
JOIN pembacaan_hama ph ON nh.id_pembacaan_hama = ph.id_pembacaan_hama
JOIN sensor_hama sh    ON ph.id_sensor_hama = sh.id_sensor_hama
JOIN lahan l           ON sh.id_lahan = l.id_lahan
JOIN hama h            ON nh.id_hama = h.id_hama;

SELECT l.nama_lahan, ROUND(AVG(p.nilai_kelembapan), 2) AS rata_rata_kelembapan
FROM lahan l
JOIN sensor_kelembapan s    ON l.id_lahan = s.id_lahan
JOIN pembacaan_kelembapan p ON s.id_sensor_kelembapan = p.id_sensor_kelembapan
GROUP BY l.id_lahan, l.nama_lahan;

SELECT p.id_pembacaan_kelembapan, p.nilai_kelembapan, p.waktu_baca
FROM pembacaan_kelembapan p
LEFT JOIN notifikasi_kelembapan n
       ON p.id_pembacaan_kelembapan = n.id_pembacaan_kelembapan
WHERE n.id_notifikasi_kelembapan IS NULL;
