#!/bin/bash

# Tworzenie folderów dla Pi-hole
mkdir -p ./etc-pihole
mkdir -p ./etc-dnsmasq.d
mkdir -p ./var-log-pihole

# Tworzenie plików konfiguracyjnych dla Pi-hole
cat <<EOF > ./etc-pihole/setupVars.conf
PIHOLE_INTERFACE=eth0
IPV4_ADDRESS=172.20.0.3
IPV6_ADDRESS=
PIHOLE_DNS_1=172.20.0.2#53
PIHOLE_DNS_2=
QUERY_LOGGING=true
INSTALL_WEB=true
BLOCKING_ENABLED=true
DNS_FQDN_REQUIRED=false
DNS_BOGUS_PRIV=false
DNSMASQ_LISTENING=all
EOF

cat <<EOF > ./etc-pihole/adlists.list
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://adaway.org/hosts.txt
https://hole.cert.pl/domains/v2/domains.txt
https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts
https://v.firebog.net/hosts/static/w3kbl.txt
https://v.firebog.net/hosts/AdguardDNS.txt
https://v.firebog.net/hosts/Admiral.txt
https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
https://v.firebog.net/hosts/Easylist.txt
https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts
https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts
https://v.firebog.net/hosts/Easyprivacy.txt
https://v.firebog.net/hosts/Prigent-Ads.txt
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts
https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt
https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt
https://v.firebog.net/hosts/Prigent-Crypto.txt
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts
https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt
https://phishing.army/download/phishing_army_blocklist_extended.txt
https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt
https://v.firebog.net/hosts/RPiList-Malware.txt
https://v.firebog.net/hosts/RPiList-Phishing.txt
https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt
https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts
https://urlhaus.abuse.ch/downloads/hostfile/
https://lists.cyberhost.uk/malware.txt
EOF

# Tworzenie folderu dla Unbound
mkdir -p ./etc-unbound

# Tworzenie pliku konfiguracyjnego dla Unbound
cat <<EOF > ./etc-unbound/unbound.conf
server:
    # Enable or disable whether the unbound server forks into the background
    # as a daemon. Default is yes.
    do-daemonize: no

    # If given, after binding the port the user privileges are dropped.
    # Default is "unbound". If you give username: "" no user change is performed.
    username: "unbound"

    # No need to chroot as this container has been stripped of all other binaries.
    chroot: ""

    # If "" is given, logging goes to stderr, or nowhere once daemonized.
    logfile: ""

    # The process id is written to the file. Not required since we are running
    # in a container with one process.
    pidfile: ""

    # The verbosity number, level 0 means no verbosity, only errors.
    verbosity: 1

    # Specify the interfaces to answer queries from by ip-address.
    # Bind to all available interfaces (0.0.0.0 and ::0).
    interface: 0.0.0.0

    do-ip4: yes
    do-udp: yes
    do-tcp: yes

    # If you have no IPv6 setup, set prefer-ip6 to no.
    prefer-ip6: no

    # Trust glue only if it is within the server's authority.
    harden-glue: yes

    # Require DNSSEC data for trust-anchored zones.
    harden-dnssec-stripped: yes

    # Disable randomization issues in DNSSEC for better compatibility.
    use-caps-for-id: no

    # Reduce EDNS reassembly buffer size to avoid fragmentation issues.
    edns-buffer-size: 1232

    # Perform prefetching of close to expired message cache entries.
    prefetch: yes

    # Fetch DS records earlier for DNSSEC.
    prefetch-key: yes

    # Keep a single thread for most setups.
    num-threads: 1

    # Cache settings to optimize RAM usage.
    msg-cache-size: 64m
    rrset-cache-size: 128m

    # Serve expired data instead of waiting for the query to be updated.
    serve-expired: yes

    # Time to serve expired data before fetching a fresh response (in seconds).
    serve-expired-ttl: 86400  # 1 day

    # Timeout for serving expired data.
    serve-expired-client-timeout: 1800  # 30 minutes

    # Access control for allowing certain IP ranges to query the server.
    access-control: 127.0.0.1/32 allow  # Localhost
    access-control: 192.168.0.0/16 allow  # Local network
    access-control: 172.16.0.0/12 allow
    access-control: 10.0.0.0/8 allow

    # Ensure privacy of local IP ranges.
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10

    # Number of file descriptors each thread can open.
    outgoing-range: 8192

    # Maximum queries each thread can handle simultaneously.
    num-queries-per-thread: 4096
EOF

# Tworzenie folderu dla Samba
mkdir -p ./etc-samba

# Tworzenie pliku konfiguracyjnego dla Samba
cat <<EOF > ./etc-samba/smb.conf
[global]
workgroup = WORKGROUP
server string = Samba Server
security = user
map to guest = Bad User
dns proxy = no

[shared-folders]
path = /mnt/shared-folders
browsable = yes
writable = yes
valid users = sambauser
read only = no
create mask = 0777
directory mask = 0777
EOF

# Tworzenie folderów dla Suricaty
mkdir -p ./etc-suricata
mkdir -p ./var-log-suricata
mkdir -p ./etc-suricata/rules

# Tworzenie plików konfiguracyjnych dla Suricaty
cat <<EOF > ./etc-suricata/suricata.yaml
%YAML 1.1
---
# Konfiguracja podstawowa
default-rule-path: /etc/suricata/rules
rule-files:
  - suricata.rules

# Tryb af-packet (zalecany dla wydajności)
af-packet:
  - interface: eth0
    threads: 4  # Zwiększenie liczby wątków, zależnie od zasobów
    cluster-id: 99
    cluster-type: cluster_flow
    use-mmap: yes
    tpacket-v3: yes

# Logowanie
logging:
  default-log-level: debug   # Zmieniono na debug, aby uzyskać więcej szczegółowych informacji
  outputs:
    - console:
        enabled: yes
        level: debug  # Więcej informacji na konsoli
    - file:
        enabled: yes
        level: debug
        filename: /var/log/suricata/suricata.log
    - eve-log:
        enabled: yes
        filetype: json
        filename: /var/log/suricata/eve.json
        types:
          - alert:
              metadata: yes
              tagged-packets: yes
          - http:
              extended: yes
          - dns:
              version: 2
          - tls:
              extended: yes
          - files:
              force-magic: yes
              force-md5: yes
          - ssh
          - smtp
    - stats:
        enabled: yes
        filename: /var/log/suricata/stats.log
        append: yes
        totals: yes
        threads: no

# Ustawienia detekcji
detect:
  profile: medium
  custom-values:
    toclient-src: 0.0.0.0/0  # Ustawienie na całą sieć
    toserver-dst: 0.0.0.0/0  # Ustawienie na całą sieć
  icmp: yes  # Włącz detekcję ICMP

# Ustawienia HTTP
app-layer:
  protocols:
    http:
      enabled: yes
      detection-ports:
        dp: 80, 8080
    tls:
      enabled: yes
      detection-ports:
        dp: 443

# Ustawienia przepływu
flow:
  enabled: yes
  timeout:
    new: 30
    established: 300
    closed: 0
  emergency-recovery: 30

# Ustawienia blokowania (wyłączone)
action-files:
  - drop:
      enabled: no
  - reject:
      enabled: no
  - pass:
      enabled: yes

# Ustawienia detekcji skanowania portów
detect-engine:
  - profile: medium
  - custom-values:
      toclient-src: 0.0.0.0/0  # Ustawienie na całą sieć
      toserver-dst: 0.0.0.0/0  # Ustawienie na całą sieć

# Ustawienia detekcji Wi-Fi (jeśli przechwytujesz ruch Wi-Fi)
# Wymaga przechwytywania ramek 802.11 za pomocą np. tcpdump
# i przekazania ich do Suricaty
pcap:
  - interface: eth0
    checksum-checks: no

# Ustawienia dla protokołów
protocols:
  icmp:
    enabled: yes  # Włącz detekcję ICMP
  tcp:
    enabled: yes
    detection-ports:
      dp: 1-65535  # Skanuj wszystkie porty TCP
  udp:
    enabled: yes
    detection-ports:
      dp: 1-65535  # Skanuj wszystkie porty UDP

# Ustawienia dla Wi-Fi (jeśli przechwytujesz ruch Wi-Fi)
wifi:
  enabled: yes  # Włącz detekcję ramek Wi-Fi
  interfaces:
    - eth0  # Podmień na odpowiedni interfejs Wi-Fi

# Ustawienia dla EVE (Extended Log Format)
eve-log:
  enabled: yes
  file: /var/log/suricata/eve.json
  types:
    - alert
    - http
    - tls
    - dns
    - flow
    - icmp
    - tcp
    - udp
    - wifi

# Ustawienia dla klasyfikacji zdarzeń
classification-file: /etc/suricata/classification.config

# Ustawienia dla referencji
reference-config: /etc/suricata/reference.config
EOF

cat <<EOF > ./etc-suricata/rules/suricata.rules
# Reguła do wykrywania ruchu HTTP
alert tcp any any -> 192.168.1.0/24 80 (msg:"HTTP Traffic Detected"; sid:1000001; rev:1;)

# Reguła do wykrywania ruchu HTTPS
alert tcp any any -> 192.168.1.0/24 443 (msg:"HTTPS Traffic Detected"; sid:1000002; rev:1;)

# Reguła do wykrywania skanowania portów TCP
alert tcp any any -> 192.168.1.0/24 any (msg:"Port Scan Detected"; flags: S; threshold: type both, track by_src, count 5, seconds 60; sid:1000003; rev:1;)

# Reguła do wykrywania skanowania portów UDP
alert udp any any -> 192.168.1.0/24 any (msg:"UDP Port Scan Detected"; threshold: type both, track by_src, count 5, seconds 60; sid:1000005; rev:1;)

# Reguła do wykrywania pingów (ICMP Echo Request)
alert icmp any any -> 192.168.1.0/24 any (msg:"ICMP Ping Detected"; sid:1000004; rev:1;)

# Reguła do wykrywania ramek deauthentication (Wi-Fi)
alert wifi any any -> any any (msg:"Wi-Fi Deauthentication Attack Detected"; wlan.fc.type_subtype: 12; sid:1000006; rev:1;)
EOF

cat <<EOF > ./etc-suricata/classification.config
# Klasyfikacje zdarzeń
config classification: not-suspicious,Not Suspicious Traffic,3
config classification: unknown,Unknown Traffic,3
config classification: bad-unknown,Potentially Bad Traffic,2
config classification: attempted-recon,Attempted Information Leak,2
config classification: successful-recon,Information Leak,2
config classification: attempted-dos,Attempted Denial of Service,2
config classification: successful-dos,Denial of Service,2
config classification: attempted-user,Attempted User Privilege Gain,1
config classification: successful-user,Successful User Privilege Gain,1
config classification: attempted-admin,Attempted Administrator Privilege Gain,1
config classification: successful-admin,Successful Administrator Privilege Gain,1
EOF

cat <<EOF > ./etc-suricata/reference.config
# Linki do zewnętrznych źródeł
config reference: cve       https://cve.mitre.org/cgi-bin/cvename.cgi?name=
config reference: nessus    https://www.tenable.com/plugins/nessus/
config reference: exploitdb https://www.exploit-db.com/exploits/
config reference: msft      https://technet.microsoft.com/security/bulletin/
config reference: url       https://suricata.io/
EOF

mkdir -p ./etc-prometheus
mkdir -p ./etc-grafana

cat <<EOF > ./etc-prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['192.168.1.5:9100']
EOF

mkdir -p ./etc-squid
mkdir -p ./var-log-squid

cat <<EOF > ./etc-squid/squid.conf
http_port 3128

# Blokowanie listy StevenBlack (porn + social)
acl blocklist_stevenblack dstdomain "/etc/squid/blocklists/stevenblack-domains.txt"
http_access deny blocklist_stevenblack

# Zezwalanie na dostęp z sieci lokalnej
acl localnet src 172.20.0.0/24
http_access allow localnet

# Logi
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
EOF

echo "Foldery i pliki konfiguracyjne zostały utworzone."