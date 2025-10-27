select count(*)
from virus_total.v_dns_queries
select count(*)
from virus_total.dns_queries

select *
from virus_total.dns_queries

select *
from virus_total.dns_queries
order by id desc 

select *
from virus_total.url_scans
order by id desc 

--url, scan_date, positives,total_scans, permalink
select url, scan_date, positives,total_scans, permalink
from virus_total.url_scans
where positives > 1

select *
from virus_total.v_dns_queries
order by id desc 

select *
from virus_total.v_malicious_url_scans 

select *
from virus_total.v_non_ipv4_response_ips 

select *
from virus_total.v_malicious_url_detailed_scans