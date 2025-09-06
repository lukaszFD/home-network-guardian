import os
import time
import pymysql
import requests
from dotenv import load_dotenv
import re

# Load environment variables from .env file
load_dotenv()

# Database configuration from environment variables
MYSQL_HOST = os.getenv('MYSQL_HOST', 'mysqldb')
MYSQL_USER = os.getenv('MYSQL_USER')
MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD')
MYSQL_DATABASE = os.getenv('MYSQL_DATABASE')

# VirusTotal scanner service endpoint
VT_SCANNER_URL = 'http://virustotal_scanner:5000/scan-url'

def is_valid_domain(domain):
    """
    Checks if a string is a valid domain name, not an IP address.
    """
    if not domain or len(domain) > 253:
        return False
    # Check for IP address format using a simple regex
    ip_pattern = re.compile(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$|^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^::ffff:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$')
    if ip_pattern.match(domain):
        return False
    # Check for invalid characters in a domain name
    if re.search(r'[^\w\.-]', domain):
        return False
    return True

def get_domains_from_db():
    """
    Fetches domains from the v_dns_queries view.
    """
    domains = []
    try:
        connection = pymysql.connect(
            host=MYSQL_HOST,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            database=MYSQL_DATABASE,
            cursorclass=pymysql.cursors.DictCursor
        )
        with connection.cursor() as cursor:
            # Query the database for domains using the view
            sql = "SELECT domain FROM v_dns_queries"
            cursor.execute(sql)
            result = cursor.fetchall()
            domains = [row['domain'] for row in result if is_valid_domain(row['domain'])]
    except Exception as e:
        print(f"Error fetching domains from database: {e}")
    finally:
        if connection:
            connection.close()
    return domains

def scan_domain_with_virustotal(domain):
    """
    Sends a domain to the VirusTotal scanner service.
    """
    try:
        data = {"url": domain}
        headers = {"Content-Type": "application/json"}
        response = requests.post(VT_SCANNER_URL, json=data, headers=headers)
        response.raise_for_status()
        print(f"Successfully sent domain '{domain}' for scanning. Response: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error sending domain '{domain}' to VirusTotal scanner: {e}")

if __name__ == "__main__":
    domains_to_scan = get_domains_from_db()

    if not domains_to_scan:
        print("No valid domains found in the v_dns_queries view. Exiting.")
    else:
        print(f"Found {len(domains_to_scan)} domains to scan.")
        for domain in domains_to_scan:
            scan_domain_with_virustotal(domain)
            print("Waiting for 900 seconds to respect API rate limits... ")
            time.sleep(900)