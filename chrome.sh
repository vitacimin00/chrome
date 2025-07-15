#!/bin/bash

echo "📦 Chromium Docker Installer (HTTPS)"
echo "-------------------------------------"

# 👉 Input user
read -p "📦 Masukkan jumlah container yang ingin dibuat: " TOTAL
read -p "🔢 Masukkan port awal (harus ganjil, misal 3001): " START_PORT
read -p "📝 Masukkan nama dasar container (contoh: chromium): " BASE_NAME

# Cek validitas input
if ! [[ "$START_PORT" =~ ^[0-9]+$ ]] || ! [[ "$TOTAL" =~ ^[0-9]+$ ]]; then
  echo "❌ Input harus berupa angka."
  exit 1
fi

if (( START_PORT % 2 == 0 )); then
  echo "❌ Port awal harus angka ganjil (karena HTTPS-nya di port ganjil)."
  exit 1
fi

# Dapatkan IP publik IPv4
IP=$(curl -4 -s ifconfig.me || hostname -I | awk '{print $1}')
IMAGE_NAME="lscr.io/linuxserver/chromium:latest"

echo ""
echo "🚀 Menjalankan $TOTAL container Chromium dari port $START_PORT..."

# Loop buat container
for i in $(seq 1 $TOTAL); do
  PORT_HTTPS=$((START_PORT + (i - 1) * 2))
  CONTAINER_NAME="${BASE_NAME}-${i}"

  echo "🧱 Membuat container $CONTAINER_NAME di port HTTPS $PORT_HTTPS..."

  docker run -d \
    --name "$CONTAINER_NAME" \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Asia/Jakarta \
    -e ENABLE_SSL=true \
    -p "$PORT_HTTPS":3001 \
    --shm-size="1gb" \
    "$IMAGE_NAME" >/dev/null
done

# Output hasil
echo ""
echo "✅ Selesai! Akses GUI Chromium kamu via browser:"
for i in $(seq 1 $TOTAL); do
  PORT_HTTPS=$((START_PORT + (i - 1) * 2))
  echo "🔗 https://$IP:$PORT_HTTPS"
done

echo ""
echo "⚠️ Abaikan warning SSL self-signed: klik 'Advanced' > 'Proceed anyway'."
