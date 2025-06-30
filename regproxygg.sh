#!/bin/bash

# Tạo firewall rule mở port 22, 80, 443 nếu chưa có
gcloud compute firewall-rules create allow-web-ssh   --allow tcp:80,tcp:443,tcp:22   --target-tags http-server,https-server   --description="Allow HTTP, HTTPS, and SSH"   --direction=INGRESS   --priority=1000   --network=default || true

# Script startup thực thi trên từng VPS
SCRIPT_CMD='#!/bin/bash
apt update -y
apt install -y wget curl -y
sleep 3
wget https://github.com/thttd94/dante-proxy-install/releases/download/v1.0.0/googlecloud.sh -O /root/googlecloud.sh
chmod +x /root/googlecloud.sh
bash /root/googlecloud.sh >> /root/install.log 2>&1
'

# Tạo 4 máy chủ tại Tokyo
for i in 1 2 3 4; do
  gcloud compute instances create proxy-tokyo-$i \
    --zone=asia-northeast1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --tags=http-server,https-server \
    --metadata=startup-script="$SCRIPT_CMD",enable-oslogin=true
done

# Tạo 4 máy chủ tại Osaka
for i in 1 2 3 4; do
  gcloud compute instances create proxy-osaka-$i \
    --zone=asia-northeast2-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --tags=http-server,https-server \
    --metadata=startup-script="$SCRIPT_CMD",enable-oslogin=true
done
