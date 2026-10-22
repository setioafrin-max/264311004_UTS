-- Tabel Induk 1: HAMA
CREATE TABLE hama (
  id_hama    INT(11)       NOT NULL AUTO_INCREMENT,
  nama_hama  VARCHAR(100)  NOT NULL,
  gejala     TEXT          DEFAULT NULL,
  PRIMARY KEY (id_hama),
  UNIQUE KEY uq_nama_hama (nama_hama)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel Induk 2: LAHAN
CREATE TABLE lahan (
  id_lahan    INT(11)        NOT NULL AUTO_INCREMENT,
  id_petani   INT(11)        NOT NULL,
  nama_lahan  VARCHAR(100)   NOT NULL,
  lokasi      VARCHAR(150)   DEFAULT NULL,
  luas_m2     DECIMAL(12,2)  NOT NULL,
  komoditas   VARCHAR(50)    NOT NULL,
  PRIMARY KEY (id_lahan),
  CONSTRAINT chk_luas_positif CHECK (luas_m2 > 0),
  INDEX idx_lahan_komoditas (komoditas)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel Transaksi: NOTIFIKASI_HAMA
CREATE TABLE notifikasi_hama (
  id_notifikasi  INT(11)       NOT NULL AUTO_INCREMENT,
  id_lahan       INT(11)       NOT NULL,
  id_hama        INT(11)       NOT NULL,
  pesan          VARCHAR(255)  NOT NULL,
  waktu_kirim    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status_baca    TINYINT(1)    NOT NULL DEFAULT 0,
  PRIMARY KEY (id_notifikasi),
  INDEX idx_notif_status (id_lahan, status_baca),
  CONSTRAINT fk_notif_lahan FOREIGN KEY (id_lahan)
    REFERENCES lahan (id_lahan),
  CONSTRAINT fk_notif_hama FOREIGN KEY (id_hama)
    REFERENCES hama (id_hama)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
