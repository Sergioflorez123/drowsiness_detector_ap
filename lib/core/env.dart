class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ypbtyhkmgpbeqyaerkzq.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_6co0-3qtZAil4CIjvT2pnw_Ge2eLz8g',
  );
}

