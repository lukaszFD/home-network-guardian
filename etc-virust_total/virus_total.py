import os
import sys
import requests
import mysql.connector
from dotenv import load_dotenv
from datetime import datetime
import json
import logging
import re
from flask import Flask, request, jsonify

# Load environment variables from .env file
load_dotenv()
API_KEY = os.getenv("VIRUSTOTAL_API_KEY")

# Configure logging
LOG_FILE = "/app/logs/api_calls.log"
logging.basicConfig(filename=LOG_FILE, level=logging.INFO,
                    format='%(asctime)s - %(message)s')

# Initialize Flask app
app = Flask(__name__)

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
        logging.error(f"Error connecting to the database: {err}")
        return None

def url_exists(cursor, url):
    """
    Checks if a URL already exists in the url_scans table.
    """
    query = "SELECT EXISTS(SELECT 1 FROM url_scans WHERE url = %s LIMIT 1)"
    cursor.execute(query, (url,))
    return cursor.fetchone()[0] == 1

def file_exists(cursor, sha256):
    """
    Checks if a file (by its SHA256 hash) already exists in the file_scans table.
    """
    query = "SELECT EXISTS(SELECT 1 FROM file_scans WHERE sha256 = %s LIMIT 1)"
    cursor.execute(query, (sha256,))
    return cursor.fetchone()[0] == 1

def insert_url_scan_result(cursor, url, positives, total_scans, permalink, scan_result_json):
    """Inserts URL scan results into the database."""
    query = """
    INSERT INTO url_scans (url, scan_date, positives, total_scans, permalink, scan_result)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    data = (url, datetime.now(), positives, total_scans, permalink, scan_result_json)
    cursor.execute(query, data)
    logging.info(f"Successfully saved URL scan result for {url} to the database.")

def insert_file_scan_result(cursor, sha256, positives, total_scans, permalink, scan_result_json):
    """Inserts file scan results into the database."""
    query = """
    INSERT INTO file_scans (sha256, scan_date, positives, total_scans, permalink, scan_result)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    data = (sha256, datetime.now(), positives, total_scans, permalink, scan_result_json)
    cursor.execute(query, data)
    logging.info(f"Successfully saved file scan result for hash {sha256} to the database.")
    return cursor.lastrowid

def insert_yara_rules(cursor, scan_id, yara_rules):
    """Inserts YARA rules into the yara_detections table."""
    query = """
    INSERT INTO yara_detections (scan_id, rule_name, ruleset_name, description)
    VALUES (%s, %s, %s, %s)
    """
    for rule in yara_rules:
        data = (
            scan_id,
            rule.get("rule_name", None),
            rule.get("ruleset_name", None),
            rule.get("description", None)
        )
        cursor.execute(query, data)
    logging.info(f"Successfully saved {len(yara_rules)} YARA rules for scan ID {scan_id} to the database.")

def get_file_details_with_yara(sha256, api_key):
    """Pobiera pełne szczegóły pliku, w tym reguły YARA."""
    url = f"https://www.virustotal.com/api/v3/files/{sha256}"
    headers = {"x-apikey": api_key}
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to fetch file details for hash {sha256}: {e}")
        return None

def get_yara_rules_from_comments(sha256, api_key):
    """Pobiera reguły YARA z komentarzy do pliku."""
    url = f"https://www.virustotal.com/api/v3/files/{sha256}/comments"
    headers = {"x-apikey": api_key}
    yara_rules = []
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        comments_data = response.json()
        
        for comment in comments_data.get("data", []):
            text = comment["attributes"].get("text", "")
            # Użycie wyrażeń regularnych do wyodrębnienia reguł YARA
            rule_match = re.search(r"RULE: (.+)", text)
            ruleset_match = re.search(r"RULE_SET: (.+)", text)
            description_match = re.search(r"DESCRIPTION: (.+)", text)

            if rule_match and ruleset_match:
                yara_rules.append({
                    "rule_name": rule_match.group(1).strip(),
                    "ruleset_name": ruleset_match.group(1).strip(),
                    "description": description_match.group(1).strip() if description_match else None
                })
        return yara_rules
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to fetch comments for hash {sha256}: {e}")
        return []

@app.route('/scan-url', methods=['POST'])
def scan_url_endpoint():
    """Endpoint for scanning a URL."""
    conn = connect_to_db()
    if conn is None:
        return jsonify({"error": "Cannot connect to database"}), 500

    try:
        data = request.get_json()
        url_to_scan = data.get("url")
        if not url_to_scan:
            return jsonify({"error": "URL not provided"}), 400

        cursor = conn.cursor()
        if url_exists(cursor, url_to_scan):
            cursor.close()
            conn.close()
            return jsonify({"status": "URL already scanned"}), 200

        logging.info(f"API call initiated for URL: {url_to_scan}")

        url = "https://www.virustotal.com/api/v3/urls"
        headers = {"x-apikey": API_KEY}
        payload = {"url": url_to_scan}

        response = requests.post(url, headers=headers, data=payload)
        response.raise_for_status()
        data = response.json()

        if "data" in data and "id" in data["data"]:
            analysis_id = data["data"]["id"]
            analysis_url = f"https://www.virustotal.com/api/v3/analyses/{analysis_id}"
            
            # Polling for analysis result
            while True:
                analysis_response = requests.get(analysis_url, headers=headers)
                analysis_response.raise_for_status()
                analysis_data = analysis_response.json()
                
                status = analysis_data["data"]["attributes"]["status"]
                if status == "completed":
                    break
                
                # Wait for 10 seconds before polling again
                import time
                time.sleep(10)

            results = analysis_data["data"]["attributes"]["results"]
            positives = sum(1 for result in results.values() if result["category"] == "malicious")
            total_scans = len(results)
            permalink = analysis_data["data"]["links"]["self"]
            scan_result_json = json.dumps(analysis_data)
            
            insert_url_scan_result(cursor, url_to_scan, positives, total_scans, permalink, scan_result_json)
            conn.commit()
            return jsonify({
                "url": url_to_scan,
                "positives": positives,
                "total_scans": total_scans,
                "permalink": permalink,
                "message": "URL scanned successfully"
            }), 200

        else:
            return jsonify({"error": "Could not initiate URL scan"}), 500

    except requests.exceptions.RequestException as e:
        logging.error(f"API request failed for URL {url_to_scan}: {e}")
        return jsonify({"error": f"API request failed: {e}"}), 500
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        return jsonify({"error": f"An unexpected error occurred: {e}"}), 500
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if conn:
            conn.close()

@app.route('/scan-file', methods=['POST'])
def scan_file_endpoint():
    """Endpoint for scanning a file."""
    conn = connect_to_db()
    if conn is None:
        return jsonify({"error": "Cannot connect to database"}), 500

    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400

    file_to_scan = request.files['file']
    if file_to_scan.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        from hashlib import sha256
        file_hash = sha256(file_to_scan.read()).hexdigest()
        file_to_scan.seek(0) # Reset file pointer after hashing

        cursor = conn.cursor()
        if file_exists(cursor, file_hash):
            cursor.close()
            conn.close()
            return jsonify({"status": "File already scanned"}), 200

        logging.info(f"API call initiated for file: {file_to_scan.filename}")

        url = "https://www.virustotal.com/api/v3/files"
        headers = {"x-apikey": API_KEY}
        files = {"file": (file_to_scan.filename, file_to_scan.read(), 'application/octet-stream')}

        response = requests.post(url, headers=headers, files=files)
        response.raise_for_status()
        data = response.json()

        if "data" in data and "id" in data["data"]:
            analysis_id = data["data"]["id"]
            analysis_url = f"https://www.virustotal.com/api/v3/analyses/{analysis_id}"
            
            # Polling for analysis result
            while True:
                analysis_response = requests.get(analysis_url, headers=headers)
                analysis_response.raise_for_status()
                analysis_data = analysis_response.json()
                
                status = analysis_data["data"]["attributes"]["status"]
                if status == "completed":
                    break
                
                import time
                time.sleep(10)

            # Pobieranie reguł YARA
            yara_rules = []
            
            # 1. Próba pobrania reguł z głównego obiektu pliku
            file_details = get_file_details_with_yara(file_hash, API_KEY)
            if file_details and "data" in file_details:
                yara_rules.extend(file_details["data"]["attributes"].get("crowdsourced_yara_rules", []))
            
            # 2. Jeśli brak reguł, próba pobrania z komentarzy
            if not yara_rules:
                yara_rules.extend(get_yara_rules_from_comments(file_hash, API_KEY))

            results = analysis_data["data"]["attributes"]["results"]
            positives = sum(1 for result in results.values() if result["category"] == "malicious")
            total_scans = len(results)
            permalink = analysis_data["data"]["links"]["self"]

            scan_result_json = json.dumps(analysis_data)
            
            # Wstawienie wyniku skanowania do tabeli file_scans
            scan_id = insert_file_scan_result(cursor, file_hash, positives, total_scans, permalink, scan_result_json)
            
            # Wstawienie reguł YARA do nowej tabeli
            if yara_rules and scan_id:
                insert_yara_rules(cursor, scan_id, yara_rules)

            conn.commit()
            return jsonify({
                "filename": file_to_scan.filename,
                "positives": positives,
                "total_scans": total_scans,
                "permalink": permalink,
                "yara_rules_count": len(yara_rules),
                "message": "File scanned successfully"
            }), 200

        else:
            return jsonify({"error": "Could not initiate file scan"}), 500

    except requests.exceptions.RequestException as e:
        logging.error(f"API request failed for file {file_to_scan.filename}: {e}")
        return jsonify({"error": f"API request failed: {e}"}), 500
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        return jsonify({"error": f"An unexpected error occurred: {e}"}), 500
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if conn:
            conn.close()

@app.route('/yara-rules/search', methods=['GET'])
def search_yara_rules():
    """
    Endpoint for searching YARA rules.
    Example: http://<host>:5000/yara-rules/search?q=powershell
    """
    query = request.args.get('q')
    if not query:
        return jsonify({"error": "Search query 'q' is required"}), 400

    conn = connect_to_db()
    if conn is None:
        return jsonify({"error": "Cannot connect to database"}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        search_term = f"%{query}%"
        sql = """
        SELECT fs.sha256, fs.scan_date, yd.rule_name, yd.ruleset_name, yd.description
        FROM yara_detections yd
        JOIN file_scans fs ON yd.scan_id = fs.id
        WHERE yd.rule_name LIKE %s OR yd.ruleset_name LIKE %s OR yd.description LIKE %s
        """
        cursor.execute(sql, (search_term, search_term, search_term))
        results = cursor.fetchall()
        
        return jsonify(results), 200
    
    except Exception as e:
        logging.error(f"An unexpected error occurred during search: {e}")
        return jsonify({"error": f"An unexpected error occurred: {e}"}), 500
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)