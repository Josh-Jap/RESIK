import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Ganti dengan URL dan Anon Key dari Project Settings -> API di dashboard Supabase Anda
  static const String supabaseUrl = 'https://omapyuimorrmurughsok.supabase.co';
  static const String supabaseAnonKey ='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tYXB5dWltb3JybXVydWdoc29rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI3MDMzNDAsImV4cCI6MjEwODI3OTM0MH0.GB4dfKEwAOMycD5DkvAHycqLeV9x3tcCk0VWt2YkYvc';

  /// Inisialisasi Supabase saat aplikasi Flutter pertama kali dijalankan
  static Future<void> init() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  /// Shorthand akses client Supabase dari mana saja
  static SupabaseClient get client => Supabase.instance.client;
}
