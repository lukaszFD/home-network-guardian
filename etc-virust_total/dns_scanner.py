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

def url_exists(conn, url):
    """
    Checks if a URL already exists in the url_scans table.
    """
    try:
        cursor = conn.cursor()
        query = "SELECT EXISTS(SELECT 1 FROM url_scans WHERE url = %s LIMIT 1)"
        cursor.execute(query, (url,))
        result = cursor.fetchone()[0]
        cursor.close()
        return result == 1
    except Exception as e:
        print(f"Error checking if URL exists: {e}")
        return False

def get_domains_from_db():
    """Fetches domains from the dns_queries table."""
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
            # Query the database for domains
            sql = "SELECT domain FROM dns_queries"
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
    """Sends a domain to the VirusTotal scanner service."""
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
        print("No valid domains found in the dns_queries database. Exiting.")
    else:
        print(f"Found {len(domains_to_scan)} domains to check against url_scans table.")
        
        # Connect to the database again to check for existing URLs
        try:
            connection = pymysql.connect(
                host=MYSQL_HOST,
                user=MYSQL_USER,
                password=MYSQL_PASSWORD,
                database=MYSQL_DATABASE,
                cursorclass=pymysql.cursors.DictCursor
            )
            
            domains_to_process = [domain for domain in domains_to_scan if not url_exists(connection, domain)]
            
            if not domains_to_process:
                print("All domains already exist in url_scans table. No new domains to scan.")
            else:
                print(f"Found {len(domains_to_process)} new domains to scan.")
                for domain in domains_to_process:
                    scan_domain_with_virustotal(domain)
                    print("Waiting for 175 seconds to respect API rate limits... ")
                    time.sleep(175)
                    
        except Exception as e:
            print(f"An error occurred during database connection or processing: {e}")
        finally:
            if connection:
                connection.close()