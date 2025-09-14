CREATE PROCEDURE virus_total.clean_old_data(IN days_to_keep INT)
BEGIN
    DELETE FROM dns_queries WHERE timestamp < NOW() - INTERVAL days_to_keep DAY;
    DELETE FROM url_scans WHERE scan_date < NOW() - INTERVAL days_to_keep DAY;
    DELETE FROM file_scans WHERE scan_date < NOW() - INTERVAL days_to_keep DAY;
    -- Consider cascading deletes for yara_detections if needed
END;