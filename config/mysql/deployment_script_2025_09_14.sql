-- Database creation script
CREATE DATABASE virus_total;
CREATE USER 'hunter'@'%' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON virus_total.* TO 'hunter'@'%';
FLUSH PRIVILEGES;


-- Table creation scripts
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

CREATE TABLE IF NOT EXISTS virus_total.file_scans (
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

CREATE TABLE IF NOT EXISTS virus_total.url_scans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    url VARCHAR(2048) NOT NULL,
    scan_date DATETIME NOT NULL,
    positives INT,
    total_scans INT,
    permalink VARCHAR(2048),
    scan_result JSON,
    UNIQUE KEY (url(255))
);

CREATE TABLE virus_total.yara_detections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    scan_id INT NOT NULL,
    rule_name VARCHAR(255),
    ruleset_name VARCHAR(255),
    description TEXT,
    CONSTRAINT fk_file_scan
        FOREIGN KEY (scan_id)
        REFERENCES file_scans(id)
        ON DELETE CASCADE
);


-- Index creation scripts
ALTER TABLE virus_total.dns_queries ADD INDEX idx_domain (domain);
ALTER TABLE virus_total.dns_queries ADD INDEX idx_response_ip (response_ip);

ALTER TABLE virus_total.url_scans ADD INDEX idx_url (url);
ALTER TABLE virus_total.url_scans ADD INDEX idx_scan_date (scan_date);

ALTER TABLE virus_total.yara_detections ADD INDEX idx_rule_name (rule_name);
ALTER TABLE yvirus_total.ara_detections ADD INDEX idx_ruleset_name (ruleset_name);


-- View creation scripts
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


CREATE OR REPLACE VIEW virus_total.v_malicious_url_aggregated_scans AS
SELECT
    us.id AS scan_id,
    us.url,
    us.scan_date,
    us.positives,
    GROUP_CONCAT(
        CONCAT(
            jt.engine_name, 
            ' - ', 
            JSON_UNQUOTE(JSON_EXTRACT(jt.details, '$.category')), 
            ' - ', 
            JSON_UNQUOTE(JSON_EXTRACT(jt.details, '$.result'))
        )
        SEPARATOR '; '
    ) AS aggregated_detections
FROM
    virus_total.url_scans AS us
JOIN
    JSON_TABLE(
        JSON_EXTRACT(us.scan_result, '$.data.attributes.results'),
        '$' COLUMNS (
            engine_name VARCHAR(255) PATH '$.engine_name',
            details JSON PATH '$'
        )
    ) AS jt
WHERE
    us.positives > 1
    AND JSON_UNQUOTE(JSON_EXTRACT(jt.details, '$.category')) = 'malicious'
GROUP BY
    us.id, us.url, us.scan_date, us.positives;

CREATE OR REPLACE VIEW virus_total.v_malicious_url_scans AS
SELECT
    id,
    url,
    scan_date,
    positives,
    total_scans,
    permalink,
    scan_result
FROM virus_total.url_scans
WHERE positives > 0;

CREATE OR REPLACE VIEW virus_total.v_non_ipv4_response_ips AS
SELECT
    id,
    timestamp,
    query_type,
    domain,
    source_ip,
    response_ip
FROM virus_total.dns_queries
WHERE
    response_ip IS NOT NULL
    AND response_ip NOT REGEXP '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';

CREATE OR REPLACE VIEW virus_total.v_yara_matches_summary AS
SELECT
    yd.rule_name,
    yd.ruleset_name,
    yd.description,
    COUNT(yd.id) AS match_count
FROM
    virus_total.yara_detections yd
GROUP BY
    yd.rule_name,
    yd.ruleset_name,
    yd.description
ORDER BY
    match_count DESC;


-- Procedure creation scripts
CREATE PROCEDURE virus_total.clean_old_data(IN days_to_keep INT)
BEGIN
    DELETE FROM dns_queries WHERE timestamp < NOW() - INTERVAL days_to_keep DAY;
    DELETE FROM url_scans WHERE scan_date < NOW() - INTERVAL days_to_keep DAY;
    DELETE FROM file_scans WHERE scan_date < NOW() - INTERVAL days_to_keep DAY;
    -- Consider cascading deletes for yara_detections if needed
END;

