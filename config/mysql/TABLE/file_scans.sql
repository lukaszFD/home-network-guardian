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