ALTER TABLE virus_total.url_scans ADD INDEX idx_url (url);
ALTER TABLE virus_total.url_scans ADD INDEX idx_scan_date (scan_date);