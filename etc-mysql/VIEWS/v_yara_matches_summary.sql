CREATE OR REPLACE VIEW virus_total.v_yara_matches_summary AS
SELECT
    yd.rule_name,
    yd.ruleset_name,
    yd.description,
    COUNT(yd.id) AS match_count
FROM
    virus_total.yara_detections yd
GROUP BY
    yd.rule_name,
    yd.ruleset_name,
    yd.description
ORDER BY
    match_count DESC;