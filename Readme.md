# SMBScanner

## Overview
SMBScanner is a simple Bash script that scans a given subnet for SMB servers and detects vulnerable SMB shares, SMB version, and signing status.

## Features
- Scan a subnet for open SMB servers
- List vulnerable SMB shares
- Check SMB version (Detect SMBv1)
- Check SMB signing status

## Installation
```bash
chmod +x install.sh
sudo ./install.sh
```

## Usage
```bash
smbscanner -T <subnet> -P <password> [options]
```

### Options:
```
-T, --target <subnet>       Specify the target subnet (e.g., 192.168.1.0/24). This is mandatory.
-P, --password <password>   Specify the password for SMB connections. This is mandatory unless -N is used.
-U, --username <username>   Specify the username for SMB connections (e.g., 'user@domain'). Optional.
-N, --no-pass               Connect to SMB servers without a password. Overrides -P if used. Optional.
    --only-ip               List only the IP addresses of SMB servers with vulnerable SMB shares. Optional.
-sV, --smb-version          List IP addresses that have SMBv1 version. Optional.
-sS, --smb-sign             Check SMB signing status. Optional.
-V, --version               Display the version of the script. Optional.
-h, --help                  Display this help message and exit.
```

### Example Usage
```bash
smbscanner -T 192.168.1.0/24 -P 'password123'
smbscanner -T 192.168.1.0/24 -P 'password123' -U 'admin@domain'
smbscanner -T 192.168.1.0/24 -N --only-ip
```

## Requirements
- Linux-based OS
- nmap
- smbclient

---

# SMBScanner

## Genel Bakış
SMBScanner, belirtilen bir subnet'te açık SMB sunucularını tarayan, zafiyet içeren SMB paylaşımlarını tespit eden ve SMB sürümü ile imzalama durumunu kontrol eden basit bir Bash betiğidir.

## Özellikler
- Açık SMB sunucularını tarar
- Zafiyet içeren SMB paylaşımlarını listeler
- SMB sürümünü kontrol eder (SMBv1 tespiti yapar)
- SMB imzalama durumunu kontrol eder

## Kurulum
```bash
chmod +x install.sh
sudo ./install.sh
```

## Kullanım
```bash
smbscanner -T <subnet> -P <password> [options]
```

### Parametreler:
```
-T, --target <subnet>       Hedef subnet'i belirtin (örn: 192.168.1.0/24). Zorunludur.
-P, --password <password>   SMB bağlantısı için parola belirtin. Zorunludur, -N kullanılıyorsa gereksizdir.
-U, --username <username>   SMB bağlantısı için kullanıcı adı belirtin (örn: 'user@domain'). Opsiyoneldir.
-N, --no-pass               SMB sunucularına parola olmadan bağlanır. Kullanıldığında -P'yi geçersiz kılar. Opsiyoneldir.
    --only-ip               Zafiyet içeren SMB paylaşımı olan IP adreslerini listeler. Opsiyoneldir.
-sV, --smb-version          SMBv1 kullanan IP adreslerini listeler. Opsiyoneldir.
-sS, --smb-sign             SMB imzalama durumunu kontrol eder. Opsiyoneldir.
-V, --version               Betiğin sürümünü gösterir. Opsiyoneldir.
-h, --help                  Yardım mesajını gösterir ve çıkar.
```

### Kullanım Örnekleri
```bash
smbscanner -T 192.168.1.0/24 -P 'password123'
smbscanner -T 192.168.1.0/24 -P 'password123' -U 'admin@domain'
smbscanner -T 192.168.1.0/24 -N --only-ip
```

## Gereksinimler
- Linux tabanlı işletim sistemi
- nmap
- smbclient

