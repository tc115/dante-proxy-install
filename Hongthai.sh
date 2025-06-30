#!/bin/bash

# Đặt prefix cho tên project
PROJECT_PREFIX="proxygen"
NUM_PROJECTS=3
REG_SCRIPT_URL="https://github.com/thttd94/dante-proxy-install/releases/download/v1.0.0/regproxygg.sh"

# Tạo mảng để lưu các Project ID đã tạo
PROJECT_IDS=()

# Bước 1: Tạo toàn bộ project trước
for i in $(seq 1 $NUM_PROJECTS); do
    RAW_ID="${PROJECT_PREFIX}-${RANDOM}"
    PROJECT_ID="$RAW_ID"
    PROJECT_IDS+=("$PROJECT_ID")

    echo -e "\n>>> [${i}] Tạo project: $PROJECT_ID"
    gcloud projects create "$PROJECT_ID" --name="$PROJECT_ID"

    BILLING_ACCOUNT=$(gcloud beta billing accounts list --format="value(ACCOUNT_ID)" | head -n 1)
    gcloud beta billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT"

    gcloud services enable compute.googleapis.com --project="$PROJECT_ID"
done

# Bước 2: Tạo proxy cho từng project
for PROJECT_ID in "${PROJECT_IDS[@]}"; do
    echo -e "\n>>> Thực hiện tạo proxy cho project: $PROJECT_ID"
    gcloud config set project "$PROJECT_ID"

    wget -q "$REG_SCRIPT_URL" -O regproxygg.sh
    chmod +x regproxygg.sh
    ./regproxygg.sh
done

# Bước 3: Hiển thị toàn bộ 24 proxy sau khi đã tạo xong
echo -e "\n✅ Danh sách toàn bộ proxy (24 proxy Tokyo + Osaka):"
for PROJECT_ID in "${PROJECT_IDS[@]}"; do
    gcloud config set project "$PROJECT_ID" > /dev/null
    gcloud compute instances list         --filter="name~'^proxy-(tokyo|osaka)'"         --format="value(EXTERNAL_IP)" |
        awk '{print $1":443:Baoanh:proxy123"}'
done
