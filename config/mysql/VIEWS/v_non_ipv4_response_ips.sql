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