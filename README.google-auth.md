# Mengaktifkan Login dengan Google di Sistem Ananda Group

Dokumen ini menjelaskan cara mengaktifkan dan menggunakan fitur "Login with Google" di aplikasi Sistem Ananda Group.

## Prasyarat

1. Akun Google Cloud Platform
2. Project Supabase yang aktif
3. Akses ke dashboard Supabase

## Langkah-langkah Implementasi

### 1. Konfigurasi di Google Cloud Platform

Untuk mengaktifkan OAuth dengan Google, Anda perlu membuat kredensial OAuth di Google Cloud Platform:

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Buat project baru atau pilih project yang sudah ada
3. Aktifkan Google Identity API
4. Navigasi ke "APIs & Services" > "Credentials"
5. Klik "Create Credentials" dan pilih "OAuth client ID"
6. Pilih "Web application" sebagai Application type
7. Berikan nama untuk OAuth client (misalnya "Sistem Ananda Group")
8. Tambahkan URI berikut di "Authorized JavaScript origins":
   - `https://[YOUR_SUPABASE_PROJECT_REF].supabase.co`
   - URL produksi aplikasi Anda
   - `http://localhost:5173` (untuk pengembangan lokal)
9. Tambahkan URI berikut di "Authorized redirect URIs":
   - `https://[YOUR_SUPABASE_PROJECT_REF].supabase.co/auth/v1/callback`
10. Klik "Create"
11. Salin "Client ID" dan "Client Secret" yang dihasilkan

### 2. Konfigurasi di Supabase

1. Buka dashboard Supabase dan pilih project Anda
2. Navigasi ke "Authentication" > "Providers"
3. Cari "Google" dan aktifkan dengan mengklik toggle
4. Masukkan "Client ID" dan "Client Secret" yang Anda dapatkan dari Google Cloud Console
5. Simpan perubahan

### 3. Konfigurasi URL Redirect

1. Di dashboard Supabase, navigasi ke "Authentication" > "URL Configuration"
2. Pastikan "Site URL" diatur ke URL produksi aplikasi Anda atau `http://localhost:5173` untuk pengembangan lokal
3. Tambahkan URL redirect tambahan jika diperlukan (misalnya `http://localhost:5173/dashboard`)
4. Simpan perubahan

## Cara Kerja

Ketika pengguna mengklik tombol "Log in with Google":

1. Aplikasi memanggil `supabase.auth.signInWithOAuth({ provider: 'google' })`
2. Pengguna diarahkan ke halaman login Google
3. Setelah berhasil login, Google mengirimkan kode otorisasi ke Supabase
4. Supabase menukar kode otorisasi dengan token akses
5. Supabase membuat sesi untuk pengguna dan mengarahkan kembali ke aplikasi
6. Aplikasi menerima token sesi dan menggunakannya untuk autentikasi

## Troubleshooting

Jika Anda mengalami masalah dengan login Google, periksa hal-hal berikut:

1. Pastikan "Client ID" dan "Client Secret" dimasukkan dengan benar di Supabase
2. Pastikan URL yang dikonfigurasi di Google Cloud Console dan Supabase cocok
3. Periksa konsol browser untuk melihat error yang mungkin terjadi
4. Pastikan domain aplikasi Anda diizinkan di Google Cloud Console

## Catatan Penting

- Untuk pengembangan lokal, Anda mungkin perlu menggunakan `http://localhost:5173` sebagai URL redirect
- Untuk produksi, pastikan untuk menggunakan HTTPS untuk URL aplikasi Anda
- Jika Anda mengubah URL aplikasi, pastikan untuk memperbarui konfigurasi di Google Cloud Console dan Supabase
