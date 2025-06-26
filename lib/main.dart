import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your main app widget and API constants.
// Ensure these files exist in the specified paths relative to your lib folder.
import 'package:unmute/app/unmute_app.dart';
import 'package:unmute/core/utils/app_utils.dart';

/// The main entry point of the Flutter application.
/// This function initializes essential services before the UI starts.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase.

  await Supabase.initialize(
    url: 'https://tjcsaizuicqhujpogtye.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqY3NhaXp1aWNxaHVqcG9ndHllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4NjU1NTgsImV4cCI6MjA2NDQ0MTU1OH0.LQ6cuQc0T35VKRSxKMmDQgXXlckjhgmKBVE6Vp4-9FM',
  );

  await AppUtils.setPreferredLocale();

  // Run the main application widget.
  // This widget (UnmuteApp) will be the root of your entire UI tree.
  runApp(const UnmuteApp());
}
