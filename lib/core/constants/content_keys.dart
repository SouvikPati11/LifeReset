/// Single source of truth for the Firestore paths and field keys used by the
/// admin-managed help & legal content.
///
/// Both the Admin Panel (writes) and the user-facing Support feature (reads)
/// import these, so the admin→user data path cannot drift out of sync.
class ContentPaths {
  const ContentPaths._();

  /// App-wide config/content collection (readable by any signed-in user;
  /// writable only by admins — see firestore.rules `app_config/{docId}`).
  static const String appConfig = 'app_config';

  /// Document ids under [appConfig].
  static const String termsDoc = 'terms';
  static const String helpDoc = 'help';
  static const String generalDoc = 'general';

  /// FAQ collection (its own firestore.rules block).
  static const String faqs = 'faqs';
}

/// Field keys shared between admin writes and user reads.
class ContentKeys {
  const ContentKeys._();

  // Content pages (terms / help).
  static const String title = 'title';
  static const String body = 'body';

  // FAQs.
  static const String question = 'question';
  static const String answer = 'answer';
  static const String order = 'order';
  static const String status = 'status';

  // Contact support (stored on app_config/general).
  static const String supportEmail = 'supportEmail';
  static const String supportPhone = 'supportPhone';
  static const String supportMessage = 'supportMessage';
}
