CREATE DATABASE virus_total;
CREATE USER 'hunter'@'%' IDENTIFIED BY 'lfd1984';
GRANT ALL PRIVILEGES ON virus_total.* TO 'hunter'@'%';
FLUSH PRIVILEGES;

CREATE TABLE IF NOT EXISTS url_scans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    url VARCHAR(2048) NOT NULL,
    scan_date DATETIME NOT NULL,
    positives INT,
    total_scans INT,
    permalink VARCHAR(2048),
    scan_result JSON,
    UNIQUE KEY (url(255))
);

CREATE TABLE IF NOT EXISTS file_scans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sha256 VARCHAR(64) NOT NULL,
    scan_date DATETIME NOT NULL,
    positives INT,
    total_scans INT,
    permalink VARCHAR(2048),
    yara_rules JSON,
    scan_result JSON,
    UNIQUE KEY (sha256)
);

CREATE DATABASE dns_logs;
CREATE USER 'hunter'@'%' IDENTIFIED BY 'lfd1984';
GRANT ALL PRIVILEGES ON dns_logs.* TO 'hunter'@'%';
FLUSH PRIVILEGES;

CREATE TABLE `dns_queries` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `timestamp` DATETIME NOT NULL,
  `query_type` VARCHAR(10) NOT NULL,
  `domain` VARCHAR(255) NOT NULL,
  `source_ip` VARCHAR(45) NOT NULL,
  `response_ip` VARCHAR(45),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_dns_entry` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;