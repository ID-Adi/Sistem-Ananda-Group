#!/bin/bash

# Instal nvm jika belum ada
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Instal dan gunakan Node.js versi LTS
nvm install --lts
nvm use --lts

# Instal dependensi dan jalankan aplikasi
echo "Menginstal dependensi server..."
cd ~/Documents/Source\ Code/windsurf/server
npm install

echo "Menginstal dependensi client..."
cd ~/Documents/Source\ Code/windsurf/client
npm install

echo "Setup selesai! Jalankan aplikasi dengan perintah berikut:"
echo "Terminal 1: cd ~/Documents/Source\ Code/windsurf/server && npm run dev"
echo "Terminal 2: cd ~/Documents/Source\ Code/windsurf/client && npm run dev"
