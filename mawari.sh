#!/bin/bash

# Mawari Guardian Node Manager (Multi-Container + Auto Update + Rename)
# by Jackxyz72 :)

# Variabel default
IMAGE="us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest"
CACHE_DIR="$HOME/mawari"

# Fungsi: instal Docker
install_docker() {
    echo "🔧 Menginstal Docker..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "✅ Docker terinstal."
}

# Fungsi: jalankan node baru
start_node() {
    read -p "Masukkan nama container: " NODE_NAME
    read -p "Masukkan alamat wallet (0x...): " OWNER_ADDRESS
    mkdir -p $CACHE_DIR/$NODE_NAME
    echo "🚀 Menjalankan Mawari Node ($NODE_NAME)..."
    docker run -d --name $NODE_NAME --pull always \
        -v $CACHE_DIR/$NODE_NAME:/app/cache \
        -e OWNERS_ALLOWLIST=$OWNER_ADDRESS \
        $IMAGE
    echo "✅ Node $NODE_NAME dijalankan."
}

# Fungsi: hentikan node
stop_node() {
    echo "📦 Daftar container:"
    docker ps -a --format "table {{.Names}}\t{{.Status}}"
    echo ""
    read -p "Masukkan nama container yang mau dihentikan: " NODE_NAME
    docker stop $NODE_NAME && docker rm $NODE_NAME
    echo "✅ Node $NODE_NAME dihentikan & dihapus."
}

# Fungsi: cek status semua node
status_node() {
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
}

# Fungsi: lihat log node
logs_node() {
    echo "📦 Daftar container:"
    docker ps -a --format "table {{.Names}}\t{{.Status}}"
    echo ""
    read -p "Masukkan nama container untuk lihat log: " NODE_NAME
    docker logs -f $NODE_NAME
}

# Fungsi: auto update node
update_node() {
    echo "📦 Daftar container:"
    docker ps -a --format "table {{.Names}}\t{{.Status}}"
    echo ""
    read -p "Masukkan nama container untuk update: " NODE_NAME
    echo "🔄 Pull image terbaru..."
    docker pull $IMAGE
    echo "🛑 Stop $NODE_NAME..."
    docker stop $NODE_NAME
    echo "🚀 Jalankan ulang $NODE_NAME dengan image terbaru..."
    docker rm $NODE_NAME
    docker run -d --name $NODE_NAME \
        -v $CACHE_DIR/$NODE_NAME:/app/cache \
        -e OWNERS_ALLOWLIST=$OWNER_ADDRESS \
        $IMAGE
    echo "✅ Node $NODE_NAME berhasil diperbarui."
}

# Fungsi: rename container
rename_node() {
    echo "📦 Daftar container:"
    docker ps -a --format "table {{.Names}}\t{{.Status}}"
    echo ""
    read -p "Masukkan nama container lama: " OLD_NAME
    read -p "Masukkan nama container baru: " NEW_NAME
    echo "🛑 Menghentikan container $OLD_NAME..."
    docker stop $OLD_NAME
    echo "✏️ Rename $OLD_NAME → $NEW_NAME..."
    docker rename $OLD_NAME $NEW_NAME
    echo "🚀 Menjalankan kembali $NEW_NAME..."
    docker start $NEW_NAME
    echo "✅ Container berhasil di-rename!"
}

# Menu interaktif
while true; do
    clear
    echo "======================================="
    echo "   Mawari Guardian Node Multi-Manager  "
    echo "======================================="
    echo "1) Instal Docker"
    echo "2) Jalankan Node Baru"
    echo "3) Hentikan Node"
    echo "4) Cek Status Semua Node"
    echo "5) Lihat Log Node"
    echo "6) Auto Update Node"
    echo "7) Rename Container"
    echo "8) Keluar"
    echo "======================================="
    read -p "Pilih menu [1-8]: " choice

    case $choice in
        1) install_docker ;;
        2) start_node ;;
        3) stop_node ;;
        4) status_node ;;
        5) logs_node ;;
        6) update_node ;;
        7) rename_node ;;
        8) echo "👋 Keluar..."; exit 0 ;;
        *) echo "❌ Pilihan tidak valid!";;
    esac

    echo ""
    read -p "Tekan [Enter] untuk kembali ke menu..."
done

