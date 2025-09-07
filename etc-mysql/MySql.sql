select count(*)
from virus_total.v_dns_queries

select count(*)
from virus_total.url_scans

select *
from virus_total.v_dns_queries

select *
from virus_total.v_dns_queries
order by id desc

select *
from virus_total.dns_queries
where domain = 'spot-pa.googleapis.com'

select *
from virus_total.url_scans
order by id desc 

select *
from virus_total.url_scans
where positives > 0 


