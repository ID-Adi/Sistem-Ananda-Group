import { supabase } from '../supabase'

/**
 * Memeriksa apakah email diizinkan untuk mengakses aplikasi
 * @param {string} email - Email yang akan diperiksa
 * @returns {Promise<boolean>} - True jika email diizinkan, false jika tidak
 */
export const isEmailAllowed = async (email) => {
  try {
    const { data, error } = await supabase
      .from('allowed_emails')
      .select('*')
      .eq('email', email)
      .eq('is_active', true)
      .single();
    
    if (error || !data) {
      console.error('Email tidak diizinkan:', email);
      return false;
    }
    
    return true;
  } catch (error) {
    console.error('Error memeriksa email:', error);
    return false;
  }
}

/**
 * Menambahkan email ke daftar yang diizinkan (hanya untuk admin)
 * @param {string} email - Email yang akan ditambahkan
 * @param {string} description - Deskripsi opsional
 * @returns {Promise<{success: boolean, message: string}>} - Status operasi
 */
export const addAllowedEmail = async (email, description = '') => {
  try {
    const { data, error } = await supabase
      .from('allowed_emails')
      .insert([{ email, description }]);
    
    if (error) {
      return { success: false, message: error.message };
    }
    
    return { success: true, message: 'Email berhasil ditambahkan' };
  } catch (error) {
    return { success: false, message: error.message };
  }
}

/**
 * Menghapus email dari daftar yang diizinkan (hanya untuk admin)
 * @param {string} email - Email yang akan dihapus
 * @returns {Promise<{success: boolean, message: string}>} - Status operasi
 */
export const removeAllowedEmail = async (email) => {
  try {
    const { data, error } = await supabase
      .from('allowed_emails')
      .delete()
      .eq('email', email);
    
    if (error) {
      return { success: false, message: error.message };
    }
    
    return { success: true, message: 'Email berhasil dihapus' };
  } catch (error) {
    return { success: false, message: error.message };
  }
}

/**
 * Mendapatkan daftar email yang diizinkan (hanya untuk admin)
 * @returns {Promise<Array>} - Daftar email yang diizinkan
 */
export const getAllowedEmails = async () => {
  try {
    const { data, error } = await supabase
      .from('allowed_emails')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) {
      console.error('Error mendapatkan daftar email:', error);
      return [];
    }
    
    return data || [];
  } catch (error) {
    console.error('Error mendapatkan daftar email:', error);
    return [];
  }
}
