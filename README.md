# Sistem Akuntansi & Inventory

Aplikasi berbasis web untuk manajemen akuntansi dan inventory dengan menggunakan Node.js, Vue.js, dan Supabase.

## Struktur Proyek

Proyek ini terdiri dari dua bagian utama:

- **server**: Backend menggunakan Node.js dan Express
- **client**: Frontend menggunakan Vue.js 3 dan Vuetify

## Cara Menjalankan Aplikasi

### Prasyarat

- Node.js (versi 14 atau lebih tinggi)
- NPM atau Yarn
- Akun Supabase (untuk autentikasi dan database)

### Langkah-langkah

1. **Konfigurasi Supabase**
   - Buat proyek baru di [Supabase](https://supabase.com)
   - Salin URL dan Anon Key dari proyek Supabase Anda
   - Update file `.env` di folder `client` dengan kredensial Supabase Anda

2. **Menjalankan Backend**
   ```bash
   cd server
   npm install
   npm run dev
   ```

3. **Menjalankan Frontend**
   ```bash
   cd client
   npm install
   npm run dev
   ```

4. Buka browser dan akses `http://localhost:5173`

## Fitur

- Autentikasi menggunakan Supabase
- Dashboard dengan ringkasan data akuntansi dan inventory
- Modul Akuntansi (dalam pengembangan)
- Modul Inventory (dalam pengembangan)
- Laporan (dalam pengembangan)

## Pengembangan Selanjutnya

- Implementasi fitur akuntansi lengkap (jurnal, buku besar, neraca)
- Implementasi fitur inventory lengkap (stok, pembelian, penjualan)
- Integrasi dengan Supabase untuk penyimpanan data
- Laporan dan analitik
