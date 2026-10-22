CREATE TABLE `lahan` (
  `id_lahan`   INT(11)       NOT NULL AUTO_INCREMENT,
  `id_petani`  INT(11)       NOT NULL,
  `nama_lahan` VARCHAR(100)  NOT NULL,
  `lokasi`     VARCHAR(150)  DEFAULT NULL,
  `luas_m2`    DECIMAL(12,2) NOT NULL CHECK (`luas_m2` > 0),
  `komoditas`  VARCHAR(50)   NOT NULL,
  PRIMARY KEY (`id_lahan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `kegiatan` (
  `id_kegiatan`   INT(11)      NOT NULL AUTO_INCREMENT,
  `nama_kegiatan` VARCHAR(100) NOT NULL,
  `satuan`        VARCHAR(20)  NOT NULL,
  PRIMARY KEY (`id_kegiatan`),
  UNIQUE KEY `nama_kegiatan` (`nama_kegiatan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `aktivitas_lahan` (
  `id_aktivitas`     BIGINT(20)    NOT NULL AUTO_INCREMENT,
  `id_lahan`         INT(11)       NOT NULL,
  `id_kegiatan`      INT(11)       NOT NULL,
  `jumlah`           DECIMAL(10,2) NOT NULL CHECK (`jumlah` >= 0),
  `waktu_aktivitas`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sumber_aktivitas` ENUM('MANUAL','OTOMATIS') NOT NULL DEFAULT 'MANUAL',
  PRIMARY KEY (`id_aktivitas`),
  CONSTRAINT `fk_aktivitas_lahan`
    FOREIGN KEY (`id_lahan`) REFERENCES `lahan` (`id_lahan`),
  CONSTRAINT `fk_aktivitas_kegiatan`
    FOREIGN KEY (`id_kegiatan`) REFERENCES `kegiatan` (`id_kegiatan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
