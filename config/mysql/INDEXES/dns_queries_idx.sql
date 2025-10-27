ALTER TABLE virus_total.dns_queries ADD INDEX idx_domain (domain);
ALTER TABLE virus_total.dns_queries ADD INDEX idx_response_ip (response_ip);