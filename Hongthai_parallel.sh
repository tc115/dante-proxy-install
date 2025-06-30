#!/bin/bash

PROJECT_PREFIX="proxygen"
NUM_PROJECTS=3
REG_SCRIPT_URL="https://github.com/tc115/dante-proxy-install/blob/master/regproxygg.sh"
PROJECT_IDS=()

# Tạo toàn bộ project
for i in $(seq 1 $NUM_PROJECTS); do
    PROJECT_ID="${PROJECT_PREFIX}-${RANDOM}"
    PROJECT_IDS+=("$PROJECT_ID")

    echo -e "\\n>>> [${i}] Tạo project: $PROJECT_ID"
    gcloud projects create "$PROJECT_ID" --name="$PROJECT_ID"
    BILLING_ACCOUNT=$(gcloud beta billing accounts list --format="value(ACCOUNT_ID)" | head -n 1)
    gcloud beta billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT"
    gcloud services enable compute.googleapis.com --project="$PROJECT_ID"
done

# Chạy tạo proxy tuần tự từng project — an toàn tuyệt đối
for PROJECT_ID in "${PROJECT_IDS[@]}"; do
    echo -e "\\n>>> Đang tạo proxy cho project: $PROJECT_ID"
    gcloud config set project "$PROJECT_ID" > /dev/null
    wget -q "$REG_SCRIPT_URL" -O regproxygg.sh
    chmod +x regproxygg.sh
    ./regproxygg.sh
done


echo -e "✅ Danh sách toàn bộ proxy (Tokyo + Osaka):\n"

# Lọc các project bắt đầu bằng "proxygen-"
PROJECT_IDS=$(gcloud projects list --format="value(projectId)" --filter="name~'proxygen-'")

for PROJECT_ID in $PROJECT_IDS; do
    gcloud config set project "$PROJECT_ID" > /dev/null 2>&1

    gcloud compute instances list \
        --filter="name~'^proxy-(tokyo|osaka)'" \
        --format="value(EXTERNAL_IP)" |
        awk '{print $1":443:Baoanh:proxy123"}'
done
