<template>
  <div>
    <v-app-bar color="primary" dark>
      <v-app-bar-title>Sistem Akuntansi & Inventory</v-app-bar-title>
      <v-spacer></v-spacer>
      <v-btn icon @click="toggleDrawer">
        <v-icon>mdi-menu</v-icon>
      </v-btn>
    </v-app-bar>

    <v-navigation-drawer v-model="drawer" app>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title class="text-h6">
            {{ user?.email || 'User' }}
          </v-list-item-title>
          <v-list-item-subtitle>
            {{ new Date().toLocaleDateString() }}
          </v-list-item-subtitle>
        </v-list-item-content>
        <v-list-item-action>
          <v-btn icon @click="$router.push('/profile')">
            <v-icon>mdi-account-edit</v-icon>
          </v-btn>
        </v-list-item-action>
      </v-list-item>

      <v-divider></v-divider>

      <v-list dense nav>
        <v-list-item @click="currentTab = 'dashboard'" :active="currentTab === 'dashboard'">
          <v-list-item-icon>
            <v-icon>mdi-view-dashboard</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Dashboard</v-list-item-title>
        </v-list-item>

        <v-list-item @click="currentTab = 'accounting'" :active="currentTab === 'accounting'">
          <v-list-item-icon>
            <v-icon>mdi-calculator</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Akuntansi</v-list-item-title>
        </v-list-item>

        <v-list-item @click="currentTab = 'inventory'" :active="currentTab === 'inventory'">
          <v-list-item-icon>
            <v-icon>mdi-package-variant-closed</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Inventory</v-list-item-title>
        </v-list-item>

        <v-list-item @click="currentTab = 'reports'" :active="currentTab === 'reports'">
          <v-list-item-icon>
            <v-icon>mdi-file-chart</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Laporan</v-list-item-title>
        </v-list-item>

        <v-list-item @click="currentTab = 'settings'" :active="currentTab === 'settings'">
          <v-list-item-icon>
            <v-icon>mdi-cog</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Pengaturan</v-list-item-title>
        </v-list-item>

        <v-divider></v-divider>

        <v-list-item @click="handleLogout">
          <v-list-item-icon>
            <v-icon>mdi-logout</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Logout</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>

    <v-main>
      <v-container fluid>
        <!-- Dashboard -->
        <div v-if="currentTab === 'dashboard'">
          <h2 class="text-h4 mb-4">Dashboard</h2>
          
          <v-row>
            <v-col cols="12" md="6" lg="3">
              <v-card class="mx-auto" color="primary" dark>
                <v-card-title>Total Pendapatan</v-card-title>
                <v-card-text class="text-h4">
                  Rp {{ formatNumber(accountingSummary.totalRevenue) }}
                </v-card-text>
              </v-card>
            </v-col>
            
            <v-col cols="12" md="6" lg="3">
              <v-card class="mx-auto" color="error" dark>
                <v-card-title>Total Pengeluaran</v-card-title>
                <v-card-text class="text-h4">
                  Rp {{ formatNumber(accountingSummary.totalExpenses) }}
                </v-card-text>
              </v-card>
            </v-col>
            
            <v-col cols="12" md="6" lg="3">
              <v-card class="mx-auto" color="success" dark>
                <v-card-title>Laba Bersih</v-card-title>
                <v-card-text class="text-h4">
                  Rp {{ formatNumber(accountingSummary.netProfit) }}
                </v-card-text>
              </v-card>
            </v-col>
            
            <v-col cols="12" md="6" lg="3">
              <v-card class="mx-auto" color="info" dark>
                <v-card-title>Total Item</v-card-title>
                <v-card-text class="text-h4">
                  {{ inventorySummary.totalItems }} item
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
          
          <v-row class="mt-4">
            <v-col cols="12" md="8">
              <v-card>
                <v-card-title>Grafik Pendapatan & Pengeluaran</v-card-title>
                <v-card-text>
                  <div class="text-center">
                    <p class="text-body-1">Grafik akan ditampilkan di sini</p>
                  </div>
                </v-card-text>
              </v-card>
            </v-col>
            
            <v-col cols="12" md="4">
              <v-card>
                <v-card-title>Item Stok Rendah</v-card-title>
                <v-card-text>
                  <div class="text-center">
                    <p class="text-h5 text-red">{{ inventorySummary.lowStockItems }} item</p>
                    <p class="text-body-1">memerlukan perhatian</p>
                  </div>
                </v-card-text>
                <v-card-actions>
                  <v-btn block color="primary" @click="currentTab = 'inventory'">
                    Lihat Detail
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-col>
          </v-row>
        </div>
        
        <!-- Placeholder untuk tab lain -->
        <div v-else>
          <h2 class="text-h4 mb-4">{{ tabTitle }}</h2>
          <v-card>
            <v-card-text>
              <p class="text-body-1">
                Halaman {{ tabTitle }} sedang dalam pengembangan.
              </p>
            </v-card-text>
          </v-card>
        </div>
      </v-container>
    </v-main>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../supabase'
import { useRouter } from 'vue-router'
import axios from 'axios'

export default {
  name: 'DashboardView',
  setup() {
    const router = useRouter()
    const drawer = ref(true)
    const currentTab = ref('dashboard')
    const user = ref(null)
    const loading = ref(false)
    
    // Data dummy untuk dashboard
    const accountingSummary = ref({
      totalRevenue: 0,
      totalExpenses: 0,
      netProfit: 0,
      lastUpdated: null
    })
    
    const inventorySummary = ref({
      totalItems: 0,
      lowStockItems: 0,
      totalValue: 0,
      lastUpdated: null
    })
    
    const tabTitle = computed(() => {
      const titles = {
        dashboard: 'Dashboard',
        accounting: 'Akuntansi',
        inventory: 'Inventory',
        reports: 'Laporan',
        settings: 'Pengaturan'
      }
      return titles[currentTab.value] || 'Dashboard'
    })
    
    const toggleDrawer = () => {
      drawer.value = !drawer.value
    }
    
    const handleLogout = async () => {
      try {
        await supabase.auth.signOut()
        router.push('/')
      } catch (error) {
        console.error('Error saat logout:', error)
      }
    }
    
    const formatNumber = (num) => {
      return new Intl.NumberFormat('id-ID').format(num)
    }
    
    const fetchData = async () => {
      loading.value = true
      try {
        // Mengambil data dari API backend
        const [accountingRes, inventoryRes] = await Promise.all([
          axios.get('/api/accounting/summary'),
          axios.get('/api/inventory/summary')
        ])
        
        accountingSummary.value = accountingRes.data
        inventorySummary.value = inventoryRes.data
      } catch (error) {
        console.error('Error mengambil data:', error)
      } finally {
        loading.value = false
      }
    }
    
    onMounted(async () => {
      // Mengambil data user saat ini
      const { data } = await supabase.auth.getUser()
      user.value = data?.user
      
      if (!user.value) {
        router.push('/')
        return
      }
      
      // Mengambil data untuk dashboard
      fetchData()
    })
    
    return {
      drawer,
      currentTab,
      user,
      loading,
      accountingSummary,
      inventorySummary,
      tabTitle,
      toggleDrawer,
      handleLogout,
      formatNumber
    }
  }
}
</script>
