# Panduan Konfigurasi Google OAuth untuk Supabase

Untuk mengaktifkan fitur "Login with Google" di aplikasi Anda, Anda perlu mengonfigurasi Google OAuth di dashboard Supabase. Berikut adalah langkah-langkahnya:

## Langkah 1: Buat Kredensial OAuth di Google Cloud Console

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Buat project baru atau pilih project yang sudah ada
3. Navigasi ke "APIs & Services" > "Credentials"
4. Klik "Create Credentials" dan pilih "OAuth client ID"
5. Pilih "Web application" sebagai Application type
6. Berikan nama untuk OAuth client (misalnya "Sistem Ananda Group")
7. Tambahkan URI berikut di "Authorized JavaScript origins":
   - `https://[YOUR_SUPABASE_PROJECT_REF].supabase.co` (ganti [YOUR_SUPABASE_PROJECT_REF] dengan referensi project Supabase Anda)
   - URL produksi aplikasi Anda (jika ada)
   - `http://localhost:5173` (untuk pengembangan lokal)
8. Tambahkan URI berikut di "Authorized redirect URIs":
   - `https://[YOUR_SUPABASE_PROJECT_REF].supabase.co/auth/v1/callback` (ganti [YOUR_SUPABASE_PROJECT_REF] dengan referensi project Supabase Anda)
9. Klik "Create"
10. Catat "Client ID" dan "Client Secret" yang dihasilkan

## Langkah 2: Konfigurasi Google OAuth di Dashboard Supabase

1. Buka [Dashboard Supabase](https://app.supabase.io/)
2. Pilih project Anda
3. Navigasi ke "Authentication" > "Providers"
4. Cari "Google" dan aktifkan dengan mengklik toggle
5. Masukkan "Client ID" dan "Client Secret" yang Anda dapatkan dari Google Cloud Console
6. Simpan perubahan

## Langkah 3: Konfigurasi URL Redirect di Supabase

1. Di dashboard Supabase, navigasi ke "Authentication" > "URL Configuration"
2. Pastikan "Site URL" diatur ke URL produksi aplikasi Anda atau `http://localhost:5173` untuk pengembangan lokal
3. Tambahkan URL redirect tambahan jika diperlukan (misalnya `http://localhost:5173/dashboard`)
4. Simpan perubahan

## Langkah 4: Uji Login dengan Google

1. Buka aplikasi Anda
2. Klik tombol "Log in with Google"
3. Anda akan diarahkan ke halaman login Google
4. Setelah berhasil login, Anda akan diarahkan kembali ke aplikasi Anda

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
