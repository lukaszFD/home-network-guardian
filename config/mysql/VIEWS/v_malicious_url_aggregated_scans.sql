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