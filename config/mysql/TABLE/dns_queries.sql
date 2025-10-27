CREATE TABLE virus_total.dns_queries (
  `id` INT NOT NULL AUTO_INCREMENT,
  `timestamp` DATETIME NOT NULL,
  `query_type` VARCHAR(10) NOT NULL,
  `domain` VARCHAR(255) NOT NULL,
  `source_ip` VARCHAR(45) NOT NULL,
  `response_ip` VARCHAR(45),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_dns_entry` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;