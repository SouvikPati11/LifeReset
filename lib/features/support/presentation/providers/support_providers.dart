import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/content_keys.dart';
import '../../data/support_remote_data_source.dart';
import '../../domain/entities/support_content.dart';

/// Dependency graph for user-facing help & legal content.

final _supportDataSourceProvider = Provider<SupportRemoteDataSource>((ref) {
  return SupportRemoteDataSource(FirebaseFirestore.instance);
});

/// Terms of Service page content (admin-managed at `app_config/terms`).
final termsProvider = StreamProvider<LegalPage>((ref) {
  return ref.watch(_supportDataSourceProvider).watchPage(ContentPaths.termsDoc);
});

/// Help Center intro content (admin-managed at `app_config/help`).
final helpContentProvider = StreamProvider<LegalPage>((ref) {
  return ref.watch(_supportDataSourceProvider).watchPage(ContentPaths.helpDoc);
});

/// Enabled FAQs, ordered (admin-managed in the `faqs` collection).
final faqsProvider = StreamProvider<List<FaqEntry>>((ref) {
  return ref.watch(_supportDataSourceProvider).watchFaqs();
});

/// Contact-support information (admin-managed at `app_config/general`).
final supportInfoProvider = StreamProvider<SupportInfo>((ref) {
  return ref.watch(_supportDataSourceProvider).watchSupportInfo();
});
