<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-card-title class="d-flex align-center justify-space-between">
            <span>Manajemen Akses Email</span>
            <v-btn color="primary" @click="dialog = true">
              Tambah Email
            </v-btn>
          </v-card-title>
          
          <v-card-text>
            <p class="text-subtitle-1 mb-4">
              Hanya email yang terdaftar dalam daftar ini yang dapat mengakses aplikasi.
            </p>
            
            <v-data-table
              :headers="headers"
              :items="emails"
              :loading="loading"
              class="elevation-1"
            >
              <template v-slot:item.is_active="{ item }">
                <v-chip
                  :color="item.is_active ? 'success' : 'error'"
                  size="small"
                >
                  {{ item.is_active ? 'Aktif' : 'Tidak Aktif' }}
                </v-chip>
              </template>
              
              <template v-slot:item.created_at="{ item }">
                {{ formatDate(item.created_at) }}
              </template>
              
              <template v-slot:item.actions="{ item }">
                <v-btn
                  icon
                  size="small"
                  color="primary"
                  @click="toggleStatus(item)"
                  class="mr-2"
                >
                  <v-icon>{{ item.is_active ? 'mdi-cancel' : 'mdi-check-circle' }}</v-icon>
                </v-btn>
                <v-btn
                  icon
                  size="small"
                  color="error"
                  @click="confirmDelete(item)"
                >
                  <v-icon>mdi-delete</v-icon>
                </v-btn>
              </template>
            </v-data-table>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
    
    <!-- Dialog untuk menambahkan email baru -->
    <v-dialog v-model="dialog" max-width="500px">
      <v-card>
        <v-card-title>Tambah Email Baru</v-card-title>
        <v-card-text>
          <v-form ref="form" v-model="valid" @submit.prevent="addEmail">
            <v-text-field
              v-model="newEmail.email"
              label="Email"
              :rules="[v => !!v || 'Email wajib diisi', v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) || 'Email tidak valid']"
              required
            ></v-text-field>
            
            <v-text-field
              v-model="newEmail.description"
              label="Deskripsi (opsional)"
            ></v-text-field>
            
            <v-switch
              v-model="newEmail.is_active"
              label="Aktif"
              color="success"
            ></v-switch>
          </v-form>
        </v-card-text>
        
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="error" text @click="dialog = false">Batal</v-btn>
          <v-btn color="primary" text @click="addEmail" :disabled="!valid">Simpan</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    
    <!-- Dialog konfirmasi hapus -->
    <v-dialog v-model="deleteDialog" max-width="400px">
      <v-card>
        <v-card-title>Konfirmasi Hapus</v-card-title>
        <v-card-text>
          Apakah Anda yakin ingin menghapus email <strong>{{ emailToDelete?.email }}</strong> dari daftar?
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="deleteDialog = false">Batal</v-btn>
          <v-btn color="error" text @click="deleteEmail">Hapus</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
import { ref, onMounted, inject } from 'vue'
import { supabase } from '../supabase'
import { addAllowedEmail, getAllowedEmails } from '../utils/emailAccess'

export default {
  name: 'AdminEmailAccess',
  setup() {
    const showNotification = inject('showNotification')
    const emails = ref([])
    const loading = ref(true)
    const dialog = ref(false)
    const deleteDialog = ref(false)
    const emailToDelete = ref(null)
    const valid = ref(false)
    const form = ref(null)
    
    const newEmail = ref({
      email: '',
      description: '',
      is_active: true
    })
    
    const headers = [
      { title: 'Email', key: 'email' },
      { title: 'Deskripsi', key: 'description' },
      { title: 'Status', key: 'is_active' },
      { title: 'Tanggal Dibuat', key: 'created_at' },
      { title: 'Aksi', key: 'actions', sortable: false }
    ]
    
    const loadEmails = async () => {
      loading.value = true
      try {
        const data = await getAllowedEmails()
        emails.value = data
      } catch (error) {
        console.error('Error loading emails:', error)
        showNotification('Gagal memuat daftar email', 'error')
      } finally {
        loading.value = false
      }
    }
    
    const addEmail = async () => {
      if (!valid.value) return
      
      try {
        const { data, error } = await supabase
          .from('allowed_emails')
          .insert([newEmail.value])
        
        if (error) throw error
        
        showNotification('Email berhasil ditambahkan', 'success')
        dialog.value = false
        newEmail.value = { email: '', description: '', is_active: true }
        loadEmails()
      } catch (error) {
        console.error('Error adding email:', error)
        showNotification(`Gagal menambahkan email: ${error.message}`, 'error')
      }
    }
    
    const toggleStatus = async (item) => {
      try {
        const { error } = await supabase
          .from('allowed_emails')
          .update({ is_active: !item.is_active })
          .eq('id', item.id)
        
        if (error) throw error
        
        showNotification(`Status email ${item.email} berhasil diubah`, 'success')
        loadEmails()
      } catch (error) {
        console.error('Error toggling status:', error)
        showNotification(`Gagal mengubah status: ${error.message}`, 'error')
      }
    }
    
    const confirmDelete = (item) => {
      emailToDelete.value = item
      deleteDialog.value = true
    }
    
    const deleteEmail = async () => {
      if (!emailToDelete.value) return
      
      try {
        const { error } = await supabase
          .from('allowed_emails')
          .delete()
          .eq('id', emailToDelete.value.id)
        
        if (error) throw error
        
        showNotification(`Email ${emailToDelete.value.email} berhasil dihapus`, 'success')
        deleteDialog.value = false
        emailToDelete.value = null
        loadEmails()
      } catch (error) {
        console.error('Error deleting email:', error)
        showNotification(`Gagal menghapus email: ${error.message}`, 'error')
      }
    }
    
    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleString('id-ID', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
    
    onMounted(() => {
      loadEmails()
    })
    
    return {
      emails,
      loading,
      headers,
      dialog,
      deleteDialog,
      emailToDelete,
      newEmail,
      valid,
      form,
      addEmail,
      toggleStatus,
      confirmDelete,
      deleteEmail,
      formatDate
    }
  }
}
</script>
