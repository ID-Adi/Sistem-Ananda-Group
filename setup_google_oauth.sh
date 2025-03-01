#!/bin/bash

# Variabel yang perlu diubah
PROJECT_ID="sistem-ananda-group"  # Ganti dengan ID proyek yang diinginkan
PROJECT_NAME="Sistem Ananda Group"  # Ganti dengan nama proyek yang diinginkan
SUPABASE_PROJECT_REF="hrfmpheljdfrxjwbwjyh"  # Ganti dengan referensi proyek Supabase Anda

# Pastikan gcloud CLI sudah terinstall dan ter-authenticate
if ! command -v gcloud &> /dev/null; then
    echo "gcloud CLI tidak ditemukan. Silakan install terlebih dahulu."
    exit 1
fi

# Buat proyek baru (skip jika proyek sudah ada)
echo "Membuat proyek baru: $PROJECT_NAME"
gcloud projects create $PROJECT_ID --name="$PROJECT_NAME"

# Set proyek aktif
echo "Mengatur proyek aktif ke: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Aktifkan API yang diperlukan
echo "Mengaktifkan Google OAuth API..."
gcloud services enable oauth2.googleapis.com

# Buat OAuth consent screen (ini memerlukan interaksi manual di Console)
echo "
Untuk menyelesaikan setup, silakan lakukan langkah berikut secara manual di Google Cloud Console:

1. Buka: https://console.cloud.google.com/apis/credentials/consent
2. Pilih 'External' untuk User Type
3. Isi informasi yang diperlukan:
   - App name: $PROJECT_NAME
   - User support email: [Email Anda]
   - Developer contact information: [Email Anda]

4. Kemudian buat OAuth client ID:
   - Buka: https://console.cloud.google.com/apis/credentials
   - Klik 'Create Credentials' > 'OAuth client ID'
   - Pilih 'Web application'
   - Nama: $PROJECT_NAME
   - Authorized JavaScript origins:
     * https://$SUPABASE_PROJECT_REF.supabase.co
     * http://localhost:5173
   - Authorized redirect URIs:
     * https://$SUPABASE_PROJECT_REF.supabase.co/auth/v1/callback

Setelah selesai, Anda akan mendapatkan Client ID dan Client Secret.
Simpan kedua nilai tersebut untuk konfigurasi Supabase.
"

# Output informasi tambahan
echo "
URL penting:
- Google Cloud Console: https://console.cloud.google.com/apis/credentials
- Supabase Dashboard: https://app.supabase.com/project/$SUPABASE_PROJECT_REF/auth/providers

Langkah selanjutnya:
1. Konfigurasikan Google OAuth di Supabase:
   - Buka Supabase Dashboard
   - Navigasi ke Authentication > Providers
   - Aktifkan Google provider
   - Masukkan Client ID dan Client Secret yang sudah didapatkan
"
