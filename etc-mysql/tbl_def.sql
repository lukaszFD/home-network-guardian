CREATE DATABASE virus_total;
CREATE USER 'hunter'@'%' IDENTIFIED BY '';
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

CREATE OR REPLACE VIEW virus_total.v_dns_queries AS
SELECT
    dq.id,
    dq.timestamp,
    dq.query_type,
    dq.domain,
    dq.source_ip,
    dq.response_ip
FROM virus_total.dns_queries dq
LEFT JOIN virus_total.url_scans us ON dq.domain = us.url COLLATE utf8mb4_0900_ai_ci
WHERE
    us.url IS NULL
    AND dq.response_ip REGEXP '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';