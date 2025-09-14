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