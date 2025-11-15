ALTER TABLE virus_total.url_scans ADD INDEX idx_url (url(255));
ALTER TABLE virus_total.url_scans ADD INDEX idx_scan_date (scan_date);