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