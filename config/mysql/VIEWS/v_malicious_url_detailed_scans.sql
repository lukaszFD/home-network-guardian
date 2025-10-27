CREATE OR REPLACE VIEW virus_total.v_malicious_url_detailed_scans AS
WITH all_detections AS (
    SELECT
        us.id AS scan_id,
        us.url,
        us.scan_date,
        us.positives,
        jt.engine_name,
        JSON_EXTRACT(us.scan_result, CONCAT('$.data.attributes.results."', jt.engine_name, '"')) AS engine_data
    FROM
        virus_total.url_scans AS us
    JOIN
        JSON_TABLE(
            JSON_KEYS(JSON_EXTRACT(us.scan_result, '$.data.attributes.results')),
            '$[*]' COLUMNS(engine_name VARCHAR(255) PATH '$')
        ) AS jt
    WHERE
        us.positives > 0
)
SELECT
    scan_id,
    url,
    scan_date,
    positives,
    engine_name,
    JSON_UNQUOTE(JSON_EXTRACT(engine_data, '$.category')) AS category,
    JSON_UNQUOTE(JSON_EXTRACT(engine_data, '$.result')) AS result
FROM
    all_detections
WHERE
    JSON_UNQUOTE(JSON_EXTRACT(engine_data, '$.category')) = 'malicious';