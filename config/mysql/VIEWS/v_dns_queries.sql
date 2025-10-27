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
