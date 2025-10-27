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