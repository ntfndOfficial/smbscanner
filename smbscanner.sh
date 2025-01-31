#!/bin/bash

# ASCII Art
ascii_art=$(cat <<'EOF'

███████╗███╗   ███╗██████╗     ███████╗ ██████╗ █████╗ ███╗   ██╗███╗   ██╗███████╗██████╗ 
██╔════╝████╗ ████║██╔══██╗    ██╔════╝██╔════╝██╔══██╗████╗  ██║████╗  ██║██╔════╝██╔══██╗
███████╗██╔████╔██║██████╔╝    ███████╗██║     ███████║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
╚════██║██║╚██╔╝██║██╔══██╗    ╚════██║██║     ██╔══██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
███████║██║ ╚═╝ ██║██████╔╝    ███████║╚██████╗██║  ██║██║ ╚████║██║ ╚████║███████╗██║  ██║
╚══════╝╚═╝     ╚═╝╚═════╝     ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝

EOF
)

# Banner'ı yazdır
echo "$ascii_art"

# Help menu
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    script_name=$(basename "$0")
    echo "Usage: $script_name -T <subnet> -P <password> [options]"
    echo
    echo "Options:"
    echo "  -T, --target <subnet>       Specify the target subnet (e.g., 192.168.1.0/24). This is mandatory."
    echo "  -P, --password <password>   Specify the password for SMB connections. This is mandatory unless -N is used."
    echo "  -U, --username <username>   Specify the username for SMB connections (e.g., 'user@domain'). Optional."
    echo "  -N, --no-pass               Connect to SMB servers without a password. Overrides -P if used. Optional."
    echo "      --only-ip               List only the IP addresses of SMB servers with vulnerable SMB shares. Optional."
    echo "  -sV, --smb-version          List IP addresses that have SMBv1 version. Optional."
    echo "  -sS, --smb-sign             Check SMB signing status. Optional."
    echo "  -V, --version                Display the version of the script. Optional."
    echo "  -h, --help                  Display this help message and exit."
    echo
    echo "Examples:"
    echo "  $script_name -T 192.168.1.0/24 -P 'password123'"
    echo "  $script_name -T 192.168.1.0/24 -P 'password123' -U 'admin@domain'"
    echo "  $script_name -T 192.168.1.0/24 -N --only-ip"
    exit 0
fi

# Versiyon bilgisi
VERSION="2.1"

# Parametreler için değişkenler
SUBNET=""
PASSWORD=""
USERNAME=""
NO_PASS=false
ONLY_IP=false
VERSION_SCAN=false
CHECK_SIGNING=false

# Parametreleri işleme
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -T|--target) SUBNET="$2"; shift ;;
        -P|--password) PASSWORD="$2"; shift ;;
        -U|--username) USERNAME="$2"; shift ;;
        -N|--no-pass) NO_PASS=true ;;
        --only-ip) ONLY_IP=true ;;
        -sV|--smb-version) VERSION_SCAN=true ;;
        -sS|--smb-sign) CHECK_SIGNING=true ;;
        -V|--version) 
            echo "Version: $VERSION"
            exit 0 
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Zorunlu parametrelerin kontrolü
if [[ -z "$SUBNET" ]]; then
    echo "Error: -T <subnet> is required. Use -h for help."
    exit 1
fi

if [[ -z "$PASSWORD" && "$NO_PASS" == false && "$CHECK_SIGNING" == false && "$VERSION_SCAN" == false ]]; then
    echo "Error: -P <password> is required unless -N is used. Use -h for help."
    exit 1
fi

# SMB Version Scan
if [ "$VERSION_SCAN" = true ]; then
    echo "Performing SMB V1 scan on subnet $SUBNET..."
    nmap --script smb-protocols -p 139,445 --open -n "$SUBNET" | awk '/Nmap scan report/{ip=$5}/SMBv1/{print ip}'
    exit 0
fi

# SMB Signing Check
if [ "$CHECK_SIGNING" = true ]; then
    echo "Checking SMB signing status on subnet $SUBNET..."
    nmap --script=smb2-security-mode.nse -p445 --open "$SUBNET" |awk '/Nmap scan report/{ip=$NF}/Message signing/{print ip " : " substr($0, index($0, "Message signing"))}'
    exit 0
fi

# SMB parametrelerini oluştur
smbParams=""
if [[ -n "$USERNAME" ]]; then
    smbParams="$smbParams -U \"$USERNAME\""
fi
if [[ "$NO_PASS" == true ]]; then
    smbParams="$smbParams -N"
else
    smbParams="$smbParams --password=\"$PASSWORD\""
fi

# 445 portunu tarama ve IP adreslerini listeleme
IPList=$(nmap -p 445 --open -Pn "$SUBNET" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')

# Eğer IP listesi boşsa hata mesajı göster
if [[ -z "$IPList" ]]; then
    echo "No SMB servers with port 445 open were found in the subnet $SUBNET."
    exit 0
fi

# Her IP adresini kontrol et
validIPs=()
while read -r ipAdresi; do
    smbOutput=$(eval smbclient -L "\\$ipAdresi" $smbParams 2>&1)

    # Çıktıyı filtrele
    filteredOutput=$(echo "$smbOutput" | awk '!/^\s*$/ && !/Default share/ && !/Remote Admin/ && !/Remote IPC/ && !/Printer Drivers/ && !/IPC Service/ && !/Reconnecting with SMB1 for workgroup listing/ && !/Protocol negotiation to server/ && !/NT_STATUS_INVALID_NETWORK_RESPONSE/ && !/Unable to connect with SMB1 -- no workgroup available/ && !/do_connect: Connection to / && !/smbXcli_negprot_smb1_done: No compatible protocol selected by server/ && !/do_connect: Connection to .* failed \(Error NT_STATUS_RESOURCE_NAME_NOT_FOUND\)/')

    # Eğer geçerli bir sonuç varsa, IP adresini ekle
    if [[ $(echo "$filteredOutput" | wc -l) -gt 2 ]]; then
        validIPs+=("$ipAdresi")
        if [[ "$ONLY_IP" == false ]]; then
            echo "IP Address: $ipAdresi"
            echo "$filteredOutput"
            echo -e "\n" # İki boş satır ekle
        fi
    fi
done <<< "$IPList"

# Eğer sadece IP adreslerini listelemek isteniyorsa
if [[ "$ONLY_IP" == true ]]; then
    for ip in "${validIPs[@]}"; do
        echo "$ip"
    done
fi
