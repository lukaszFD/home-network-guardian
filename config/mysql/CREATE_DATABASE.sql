CREATE DATABASE virus_total;
CREATE USER '{{ mysql_app_user }}'@'%' IDENTIFIED BY '{{ mysql_password }}';
GRANT ALL PRIVILEGES ON virus_total.* TO '{{ mysql_app_user }}'@'%';
FLUSH PRIVILEGES;