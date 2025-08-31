import os
import sys
import requests
import mysql.connector
from dotenv import load_dotenv
from datetime import datetime
import json
import logging

# Load environment variables from .env file
load_dotenv()
API_KEY = os.getenv("VIRUSTOTAL_API_KEY")

# Configure logging
LOG_FILE = "/app/logs/api_calls.log"  # Sciezka do pliku logu w kontenerze
logging.basicConfig(filename=LOG_FILE, level=logging.INFO,
                    format='%(asctime)s - %(message)s')


def connect_to_db():
    """Connects to the MySQL database."""
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE"),
            charset='utf8'
        )
        return conn
    except mysql.connector.Error as err:
        print(f"Error connecting to the database: {err}")
        return None


def ip_exists(cursor, ip_address):
    """
    Checks if an IP address already exists in the virus_total_results table.
    Returns True if exists, False otherwise.
    """
    query = "SELECT EXISTS(SELECT 1 FROM virus_total_results WHERE ip_address = %s LIMIT 1)"
    cursor.execute(query, (ip_address,))
    return cursor.fetchone()[0] == 1


def insert_scan_result(cursor, ip_address, positives, total_scans, permalink, scan_result_json):
    """Inserts the scan results into the database."""
    query = """
    INSERT INTO virus_total_results (ip_address, scan_date, positives, total_scans, permalink, scan_result)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    data = (ip_address, datetime.now(), positives, total_scans, permalink, scan_result_json)
    cursor.execute(query, data)
    print(f"Successfully saved scan result for IP {ip_address} to the database.")


def scan_ip(ip_address):
    """Scans an IP address using the VirusTotal API and stores the result."""
    conn = connect_to_db()
    if conn is None:
        print("Cannot proceed without a database connection.")
        return

    cursor = conn.cursor()
    if ip_exists(cursor, ip_address):
        print(f"IP address {ip_address} already exists in the database. Skipping scan.")
        cursor.close()
        conn.close()
        return

    # Log the API call before making the request
    logging.info(f"API call initiated for IP: {ip_address}")

    url = f"https://www.virustotal.com/api/v3/ip_addresses/{ip_address}"
    headers = {"x-apikey": API_KEY}

    try:
        print(f"Scanning IP: {ip_address}...")
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()

        if "data" in data and "attributes" in data["data"]:
            attributes = data["data"]["attributes"]
            positives = attributes["last_analysis_stats"].get("malicious", 0)
            total_scans = attributes["last_analysis_stats"].get("harmless", 0) + attributes["last_analysis_stats"].get(
                "suspicious", 0) + attributes["last_analysis_stats"].get("undetected", 0) + positives
            permalink = data["data"]["links"]["self"]
            scan_result_json = json.dumps(data)

            insert_scan_result(cursor, ip_address, positives, total_scans, permalink, scan_result_json)
            conn.commit()

        else:
            print(f"No detailed reputation data found for IP: {ip_address}")

    except requests.exceptions.RequestException as e:
        print(f"Error during API request: {e}")
        logging.error(f"API request failed for IP {ip_address}: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        logging.error(f"An unexpected error occurred for IP {ip_address}: {e}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python main.py <ip_address1> [<ip_address2> ...]")
        sys.exit(1)

    ip_addresses_to_scan = sys.argv[1:]

    for ip in ip_addresses_to_scan:
        scan_ip(ip)