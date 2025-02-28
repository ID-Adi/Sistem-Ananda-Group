<template>
  <v-container>
    <v-card class="mx-auto" max-width="800">
      <v-card-title class="text-h4 mb-4">
        Profil Pengguna
      </v-card-title>
      
      <v-divider></v-divider>
      
      <v-card-text>
        <v-alert v-if="errorMessage" type="error" class="mb-4">
          {{ errorMessage }}
        </v-alert>
        
        <v-alert v-if="successMessage" type="success" class="mb-4">
          {{ successMessage }}
        </v-alert>
        
        <v-form @submit.prevent="updateProfile" ref="form">
          <v-row>
            <v-col cols="12">
              <v-text-field
                v-model="email"
                label="Email"
                prepend-icon="mdi-email"
                disabled
                readonly
              ></v-text-field>
            </v-col>
            
            <v-col cols="12">
              <v-text-field
                v-model="fullName"
                label="Nama Lengkap"
                prepend-icon="mdi-account"
                :rules="[v => !!v || 'Nama lengkap wajib diisi']"
                required
              ></v-text-field>
            </v-col>
            
            <v-col cols="12">
              <v-text-field
                v-model="phone"
                label="Nomor Telepon"
                prepend-icon="mdi-phone"
              ></v-text-field>
            </v-col>
          </v-row>
          
          <v-divider class="my-4"></v-divider>
          
          <v-row>
            <v-col cols="12">
              <v-checkbox
                v-model="changePassword"
                label="Ubah Password"
              ></v-checkbox>
            </v-col>
            
            <template v-if="changePassword">
              <v-col cols="12">
                <v-text-field
                  v-model="currentPassword"
                  label="Password Saat Ini"
                  prepend-icon="mdi-lock"
                  :type="showCurrentPassword ? 'text' : 'password'"
                  :append-icon="showCurrentPassword ? 'mdi-eye' : 'mdi-eye-off'"
                  @click:append="showCurrentPassword = !showCurrentPassword"
                  :rules="[v => !!v || 'Password saat ini wajib diisi']"
                  required
                ></v-text-field>
              </v-col>
              
              <v-col cols="12">
                <v-text-field
                  v-model="newPassword"
                  label="Password Baru"
                  prepend-icon="mdi-lock-reset"
                  :type="showNewPassword ? 'text' : 'password'"
                  :append-icon="showNewPassword ? 'mdi-eye' : 'mdi-eye-off'"
                  @click:append="showNewPassword = !showNewPassword"
                  :rules="[v => !!v || 'Password baru wajib diisi', v => v.length >= 6 || 'Password minimal 6 karakter']"
                  required
                ></v-text-field>
              </v-col>
              
              <v-col cols="12">
                <v-text-field
                  v-model="confirmNewPassword"
                  label="Konfirmasi Password Baru"
                  prepend-icon="mdi-lock-check"
                  :type="showConfirmPassword ? 'text' : 'password'"
                  :append-icon="showConfirmPassword ? 'mdi-eye' : 'mdi-eye-off'"
                  @click:append="showConfirmPassword = !showConfirmPassword"
                  :rules="[
                    v => !!v || 'Konfirmasi password wajib diisi',
                    v => v === newPassword || 'Password tidak cocok'
                  ]"
                  required
                ></v-text-field>
              </v-col>
            </template>
          </v-row>
        </v-form>
      </v-card-text>
      
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
          color="error"
          @click="$router.push('/dashboard')"
        >
          Batal
        </v-btn>
        <v-btn
          color="primary"
          @click="updateProfile"
          :loading="loading"
        >
          Simpan Perubahan
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-container>
</template>

<script>
import { ref, onMounted, inject } from 'vue'
import { supabase } from '../supabase'
import { useRouter } from 'vue-router'

export default {
  name: 'ProfileView',
  setup() {
    const router = useRouter()
    const showNotification = inject('showNotification')
    
    // Form data
    const email = ref('')
    const fullName = ref('')
    const phone = ref('')
    const changePassword = ref(false)
    const currentPassword = ref('')
    const newPassword = ref('')
    const confirmNewPassword = ref('')
    
    // UI state
    const showCurrentPassword = ref(false)
    const showNewPassword = ref(false)
    const showConfirmPassword = ref(false)
    const loading = ref(false)
    const errorMessage = ref('')
    const successMessage = ref('')
    const form = ref(null)
    
    onMounted(async () => {
      // Ambil data user saat ini
      const { data } = await supabase.auth.getUser()
      const user = data?.user
      
      if (!user) {
        router.push('/')
        return
      }
      
      email.value = user.email || ''
      
      // Ambil data profil dari metadata user
      fullName.value = user.user_metadata?.full_name || ''
      phone.value = user.user_metadata?.phone || ''
    })
    
    const updateProfile = async () => {
      // Validasi form
      if (!form.value) return
      const { valid } = await form.value.validate()
      if (!valid) return
      
      // Validasi password jika user ingin mengubah password
      if (changePassword.value) {
        if (newPassword.value !== confirmNewPassword.value) {
          errorMessage.value = 'Password baru dan konfirmasi password tidak cocok'
          return
        }
        
        if (newPassword.value.length < 6) {
          errorMessage.value = 'Password baru minimal 6 karakter'
          return
        }
      }
      
      loading.value = true
      errorMessage.value = ''
      successMessage.value = ''
      
      try {
        // Update profil user
        const { error: updateError } = await supabase.auth.updateUser({
          data: {
            full_name: fullName.value,
            phone: phone.value
          }
        })
        
        if (updateError) throw updateError
        
        // Update password jika diperlukan
        if (changePassword.value) {
          // Untuk mengubah password, kita perlu sign in ulang terlebih dahulu
          const { error: signInError } = await supabase.auth.signInWithPassword({
            email: email.value,
            password: currentPassword.value
          })
          
          if (signInError) {
            errorMessage.value = 'Password saat ini tidak valid'
            return
          }
          
          // Update password
          const { error: passwordError } = await supabase.auth.updateUser({
            password: newPassword.value
          })
          
          if (passwordError) throw passwordError
        }
        
        successMessage.value = 'Profil berhasil diperbarui'
        showNotification('Profil berhasil diperbarui', 'success')
        
        // Reset form password
        changePassword.value = false
        currentPassword.value = ''
        newPassword.value = ''
        confirmNewPassword.value = ''
      } catch (error) {
        console.error('Error update profil:', error.message)
        errorMessage.value = error.message || 'Gagal memperbarui profil'
        showNotification('Gagal memperbarui profil', 'error')
      } finally {
        loading.value = false
      }
    }
    
    return {
      email,
      fullName,
      phone,
      changePassword,
      currentPassword,
      newPassword,
      confirmNewPassword,
      showCurrentPassword,
      showNewPassword,
      showConfirmPassword,
      loading,
      errorMessage,
      successMessage,
      updateProfile,
      form
    }
  }
}
</script>
