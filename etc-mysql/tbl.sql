USE dns_logs;

CREATE TABLE IF NOT EXISTS `dns_queries` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `timestamp` DATETIME NOT NULL,
  `source_ip` VARCHAR(255) NOT NULL,
  `query_name` VARCHAR(255) NOT NULL,
  `query_type` VARCHAR(255) NOT NULL,
  `response_ip` VARCHAR(255) NULL,
  PRIMARY KEY (`id`));
  
USE dns_logs;

CREATE TABLE IF NOT EXISTS `virus_total_results` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ip_address` VARCHAR(255) NOT NULL,
  `scan_date` DATETIME NOT NULL,
  `positives` INT NOT NULL,
  `total_scans` INT NOT NULL,
  `permalink` VARCHAR(255) NULL,
  `scan_result` JSON NULL,
  PRIMARY KEY (`id`)
);