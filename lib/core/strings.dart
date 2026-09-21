class Strings {
  Strings._();

  static const String fallback = 'fr';

  static const Map<String, Map<String, String>> _t = {
    'app_name': {'fr': 'Shop', 'ar': 'Shop', 'en': 'Shop'},
    'tab_home': {'fr': 'Accueil', 'ar': 'الرئيسية', 'en': 'Home'},
    'tab_shops': {'fr': 'Boutiques', 'ar': 'المتاجر', 'en': 'Shops'},
    'tab_cart': {'fr': 'Sac', 'ar': 'الحقيبة', 'en': 'Bag'},
    'tab_profile': {'fr': 'Plus', 'ar': 'المزيد', 'en': 'More'},
    'tab_favorites': {'fr': 'Favoris', 'ar': 'المفضلة', 'en': 'Favorites'},
    'tab_categories': {'fr': 'Catégories', 'ar': 'الفئات', 'en': 'Categories'},
    'gender_women': {'fr': 'FEMME', 'ar': 'نساء', 'en': 'WOMEN'},
    'gender_men': {'fr': 'HOMME', 'ar': 'رجال', 'en': 'MEN'},
    'tab_create': {'fr': 'Rejoindre', 'ar': 'انضم', 'en': 'Join'},
    'sell_category_title': {'fr': 'Vendre', 'ar': 'بيع', 'en': 'Sell'},
    'sell_category_subtitle': {
      'fr': 'Dans quelle catégorie est l’article que tu vends ?',
      'ar': 'في أي فئة يقع المنتج الذي تبيعه؟',
      'en': 'In what category is the item you are selling?',
    },
    'vendor_gate_title': {
      'fr': 'Connexion ou inscription',
      'ar': 'الدخول أو التسجيل',
      'en': 'Login or Register'
    },
    'vendor_gate_subtitle': {
      'fr':
          'Crée ton compte pour continuer. Un seul compte suffit, même si tu achètes déjà ici.',
      'ar': 'أنشئ حسابك للمتابعة. حساب واحد يكفي، حتى إن كنت تشتري من هنا.',
      'en':
          'Create your account to continue. One account is enough, even if you already shop here.',
    },
    'vendor_gate_connected_as': {
      'fr': 'Connectée en tant que',
      'ar': 'متصلة باسم',
      'en': 'Connected as',
    },
    'vendor_gate_continue': {
      'fr': 'Continuer et créer ma boutique',
      'ar': 'متابعة وإنشاء متجري',
      'en': 'Continue and create my shop',
    },
    'vendor_gate_switch_account': {
      'fr': 'Utiliser un autre compte',
      'ar': 'استخدام حساب آخر',
      'en': 'Use a different account',
    },
    'new_arrivals': {
      'fr': 'New Arrivals',
      'ar': 'وصل حديثا',
      'en': 'New Arrivals'
    },
    'shop_now': {'fr': 'Shop now', 'ar': 'تسوق الآن', 'en': 'Shop now'},
    'explore': {'fr': 'Explorer', 'ar': 'استكشف', 'en': 'Explore'},
    'the_products': {
      'fr': 'Les produits',
      'ar': 'المنتجات',
      'en': 'The products'
    },
    'see_all_caps': {'fr': 'TOUT VOIR', 'ar': 'عرض الكل', 'en': 'SEE ALL'},
    'see_all_products_caps': {
      'fr': 'VOIR TOUS LES PRODUITS',
      'ar': 'عرض كل المنتجات',
      'en': 'SEE ALL PRODUCTS'
    },
    'sort': {'fr': 'Trier', 'ar': 'ترتيب', 'en': 'Sort'},
    'sort_newest': {'fr': 'Nouveautés', 'ar': 'الأحدث', 'en': 'Newest'},
    'sort_price_asc': {
      'fr': 'Prix croissant',
      'ar': 'السعر تصاعديا',
      'en': 'Price: low to high'
    },
    'sort_price_desc': {
      'fr': 'Prix décroissant',
      'ar': 'السعر تنازليا',
      'en': 'Price: high to low'
    },
    'price_range': {
      'fr': 'Fourchette de prix',
      'ar': 'نطاق السعر',
      'en': 'Price range'
    },
    'min': {'fr': 'Min', 'ar': 'الأدنى', 'en': 'Min'},
    'max': {'fr': 'Max', 'ar': 'الأقصى', 'en': 'Max'},
    'apply': {'fr': 'Appliquer', 'ar': 'تطبيق', 'en': 'Apply'},
    'reset': {'fr': 'Réinitialiser', 'ar': 'إعادة تعيين', 'en': 'Reset'},
    'search_hint': {
      'fr': 'Rechercher un produit ou une boutique',
      'ar': 'ابحث عن منتج أو متجر',
      'en': 'Search products and stores'
    },
    'search_hint_shops': {
      'fr': 'Rechercher une boutique',
      'ar': 'ابحث عن متجر',
      'en': 'Search a store'
    },
    'search_hint_short': {'fr': 'Rechercher', 'ar': 'بحث', 'en': 'Search'},
    'featured_shops': {
      'fr': 'Boutiques en vedette',
      'ar': 'متاجر مميزة',
      'en': 'Featured shops'
    },
    'all_products': {
      'fr': 'Tous les produits',
      'ar': 'كل المنتجات',
      'en': 'All products'
    },
    'new_products': {
      'fr': 'Nouveautés',
      'ar': 'وصل حديثا',
      'en': 'New arrivals'
    },
    'see_all': {'fr': 'Tout voir', 'ar': 'عرض الكل', 'en': 'See all'},
    'filter': {'fr': 'Filtrer', 'ar': 'تصفية', 'en': 'Filter'},
    'category': {'fr': 'Catégorie', 'ar': 'الفئة', 'en': 'Category'},
    'all_stores': {
      'fr': 'Toutes les boutiques',
      'ar': 'كل المتاجر',
      'en': 'All stores'
    },
    'all_chip': {'fr': 'Toutes', 'ar': 'الكل', 'en': 'All'},
    'clear_all': {'fr': 'Tout vider', 'ar': 'إفراغ الكل', 'en': 'Clear all'},
    'delivers_itself': {
      'fr': 'livraison par la boutique',
      'ar': 'التوصيل عبر المتجر',
      'en': 'delivers itself'
    },
    'items_count': {'fr': 'articles', 'ar': 'عناصر', 'en': 'items'},
    'store_subtotal': {
      'fr': 'Sous-total boutique',
      'ar': 'مجموع المتجر',
      'en': 'Store subtotal'
    },
    'order_summary': {
      'fr': 'Récapitulatif',
      'ar': 'ملخص الطلب',
      'en': 'Order summary'
    },
    'delivery': {'fr': 'Livraison', 'ar': 'التوصيل', 'en': 'Delivery'},
    'delivery_agreed': {
      'fr': 'À convenir avec chaque boutique',
      'ar': 'يتم الاتفاق عليها مع كل متجر',
      'en': 'Agreed with each store',
    },
    'one_order_per_store': {
      'fr':
          'Chaque boutique gère sa propre livraison. Tu passeras une commande par boutique et tu conviendras de la livraison avec elle sur WhatsApp.',
      'ar':
          'كل متجر يتكفل بتوصيله الخاص. ستقوم بطلب واحد لكل متجر وتتفق على التوصيل معه عبر واتساب.',
      'en':
          "Each store handles its own delivery. You'll place one order per store and agree the delivery with them on WhatsApp.",
    },
    'need_account_hint': {
      'fr': "Tu auras besoin d'un compte pour commander",
      'ar': 'ستحتاج إلى حساب لإتمام الطلب',
      'en': "You'll need an account to place the order",
    },
    'empty_cart': {
      'fr': 'Ton panier est vide',
      'ar': 'سلتك فارغة',
      'en': 'Your bag is empty'
    },
    'empty_cart_sub': {
      'fr': 'Ajoute des produits depuis une boutique pour commencer.',
      'ar': 'أضف منتجات من متجر للبدء.',
      'en': 'Add products from a store to get started.'
    },
    'add_to_cart': {
      'fr': 'Ajouter au sac',
      'ar': 'أضف إلى الحقيبة',
      'en': 'Add to Bag'
    },
    'added_to_bag_title': {
      'fr': 'Ajouté à ton sac',
      'ar': 'أُضيف إلى حقيبتك',
      'en': 'Added to your bag'
    },
    'go_to_bag': {
      'fr': 'Voir mon sac',
      'ar': 'الذهاب إلى الحقيبة',
      'en': 'Go to bag'
    },
    'keep_shopping': {
      'fr': 'Continuer mes achats',
      'ar': 'متابعة التسوق',
      'en': 'Keep shopping'
    },
    'checkout': {
      'fr': 'Valider la commande',
      'ar': 'إتمام الطلب',
      'en': 'Checkout'
    },
    'total': {'fr': 'Total', 'ar': 'المجموع', 'en': 'Total'},
    'quantity': {'fr': 'Quantité', 'ar': 'الكمية', 'en': 'Quantity'},
    'login': {'fr': 'Se connecter', 'ar': 'تسجيل الدخول', 'en': 'Log in'},
    'register': {
      'fr': 'Créer un compte',
      'ar': 'إنشاء حساب',
      'en': 'Create account'
    },
    'continue_with_google': {
      'fr': 'Continuer avec Google',
      'ar': 'المتابعة عبر Google',
      'en': 'Continue with Google'
    },
    'or_divider': {'fr': 'ou', 'ar': 'أو', 'en': 'or'},
    'email': {'fr': 'Email', 'ar': 'البريد الإلكتروني', 'en': 'Email'},
    'password': {'fr': 'Mot de passe', 'ar': 'كلمة المرور', 'en': 'Password'},
    'full_name': {'fr': 'Nom complet', 'ar': 'الاسم الكامل', 'en': 'Full name'},
    'phone': {'fr': 'Téléphone', 'ar': 'الهاتف', 'en': 'Phone'},
    'city': {'fr': 'Ville', 'ar': 'المدينة', 'en': 'City'},
    'address': {'fr': 'Adresse', 'ar': 'العنوان', 'en': 'Address'},
    'no_account': {
      'fr': "Pas encore de compte ? S'inscrire",
      'ar': 'ليس لديك حساب؟ سجل الآن',
      'en': "No account? Sign up"
    },
    'have_account': {
      'fr': 'Déjà un compte ? Se connecter',
      'ar': 'لديك حساب؟ سجل الدخول',
      'en': 'Already have an account? Log in'
    },
    'logout': {'fr': 'Se déconnecter', 'ar': 'تسجيل الخروج', 'en': 'Log out'},
    'my_orders': {'fr': 'Mes commandes', 'ar': 'طلباتي', 'en': 'My orders'},
    'favorites': {'fr': 'Mes favoris', 'ar': 'المفضلة', 'en': 'Favorites'},
    'become_vendor': {
      'fr': 'Nous rejoindre en tant que vendeur',
      'ar': 'انضم كبائع',
      'en': 'Join us as a vendor'
    },
    'vendor_space': {
      'fr': 'Espace vendeuse',
      'ar': 'مساحة البائعة',
      'en': 'Seller space'
    },
    'driver_space': {
      'fr': 'Espace livreur',
      'ar': 'مساحة السائق',
      'en': 'Delivery space'
    },
    'become_driver': {
      'fr': 'Livrer avec nous',
      'ar': 'التوصيل معنا',
      'en': 'Deliver with us'
    },
    'help_support': {
      'fr': 'Aide et support',
      'ar': 'المساعدة والدعم',
      'en': 'Help and Support'
    },
    'language': {'fr': 'Langue', 'ar': 'اللغة', 'en': 'Language'},
    'country_language': {'fr': 'Langue', 'ar': 'اللغة', 'en': 'Language'},
    'about_app': {'fr': 'À propos', 'ar': 'حول التطبيق', 'en': 'About'},
    'account_group': {'fr': 'Compte', 'ar': 'الحساب', 'en': 'Account'},
    'support_group': {'fr': 'Support', 'ar': 'الدعم', 'en': 'Support'},
    'follow_us': {'fr': 'suivez-nous', 'ar': 'تابعنا', 'en': 'follow us'},
    'sign_in_title': {'fr': 'Mon compte', 'ar': 'حسابي', 'en': 'My account'},
    'sign_in_sub': {
      'fr':
          'Créez votre compte pour commander plus vite et recevoir nos nouveautés.',
      'ar': 'أنشئ حسابك للطلب بشكل أسرع واستلام آخر الجديد.',
      'en': 'Create your account to order faster and get our latest arrivals.',
    },
    'sign_in_cta': {
      'fr': "SE CONNECTER OU S'INSCRIRE",
      'ar': 'تسجيل الدخول أو إنشاء حساب',
      'en': 'SIGN IN OR SIGN UP'
    },
    'help_assistance': {
      'fr': "Besoin d'aide",
      'ar': 'بحاجة إلى مساعدة',
      'en': 'Need help'
    },
    'become_vendor_row': {
      'fr': 'Nous rejoindre en tant que vendeuse',
      'ar': 'انضمي إلينا كبائعة',
      'en': 'Join us as a seller',
    },
    'comm_preferences': {
      'fr': 'Préférences de communication',
      'ar': 'تفضيلات التواصل',
      'en': 'Communication preferences'
    },
    'dark_mode': {'fr': 'Mode sombre', 'ar': 'الوضع الداكن', 'en': 'Dark mode'},
    'services_more': {
      'fr': 'Services et plus',
      'ar': 'الخدمات والمزيد',
      'en': 'Services and more'
    },
    'coming_soon': {
      'fr': 'Bientôt disponible',
      'ar': 'قريبا',
      'en': 'Coming soon'
    },
    'my_profile': {'fr': 'Mon profil', 'ar': 'ملفي الشخصي', 'en': 'My profile'},
    'my_addresses': {
      'fr': 'Mes adresses de livraison',
      'ar': 'عناوين التوصيل',
      'en': 'Delivery addresses'
    },
    'general_info': {
      'fr': 'Informations générales',
      'ar': 'معلومات عامة',
      'en': 'General information'
    },
    'first_name': {'fr': 'Prénom', 'ar': 'الاسم الأول', 'en': 'First name'},
    'last_name': {'fr': 'Nom', 'ar': 'اسم العائلة', 'en': 'Last name'},
    'country_code': {
      'fr': 'Indicatif',
      'ar': 'رمز الدولة',
      'en': 'Country code'
    },
    'phone_number': {
      'fr': 'Numéro de téléphone',
      'ar': 'رقم الهاتف',
      'en': 'Phone number'
    },
    'email_address': {
      'fr': 'Adresse email',
      'ar': 'البريد الإلكتروني',
      'en': 'Email address'
    },
    'gender': {'fr': 'Genre', 'ar': 'الجنس', 'en': 'Gender'},
    'gender_female': {'fr': 'Femme', 'ar': 'أنثى', 'en': 'Female'},
    'gender_male': {'fr': 'Homme', 'ar': 'ذكر', 'en': 'Male'},
    'gender_unspecified': {
      'fr': 'Préfère ne pas préciser',
      'ar': 'أفضل عدم التحديد',
      'en': 'Prefer not to say'
    },
    'save_changes': {
      'fr': 'ENREGISTRER LES MODIFICATIONS',
      'ar': 'حفظ التغييرات',
      'en': 'SAVE CHANGES'
    },
    'sign_out_caps': {
      'fr': 'SE DÉCONNECTER',
      'ar': 'تسجيل الخروج',
      'en': 'SIGN OUT'
    },
    'delete_account_caps': {
      'fr': 'SUPPRIMER MON COMPTE',
      'ar': 'حذف حسابي',
      'en': 'DELETE MY ACCOUNT'
    },
    'delete_account_title': {
      'fr': 'Supprimer ton compte ?',
      'ar': 'حذف حسابك؟',
      'en': 'Delete your account?'
    },
    'delete_account_body': {
      'fr':
          'Cette action est définitive : ton profil, tes boutiques et tes commandes seront supprimés. Impossible à annuler.',
      'ar':
          'هذا الإجراء نهائي: سيتم حذف ملفك ومتاجرك وطلباتك. لا يمكن التراجع عنه.',
      'en':
          'This is permanent: your profile, shops and orders will be deleted. This cannot be undone.',
    },
    'delete_account_confirm': {'fr': 'Supprimer', 'ar': 'حذف', 'en': 'Delete'},
    'order_confirmed': {
      'fr': 'Commande envoyée',
      'ar': 'تم إرسال الطلب',
      'en': 'Order sent'
    },
    'order_status_pending': {
      'fr': 'En attente',
      'ar': 'قيد الانتظار',
      'en': 'Pending'
    },
    'order_status_confirmed': {
      'fr': 'Confirmée',
      'ar': 'مؤكدة',
      'en': 'Confirmed'
    },
    'order_status_preparing': {
      'fr': 'En préparation',
      'ar': 'قيد التحضير',
      'en': 'Preparing'
    },
    'order_status_delivering': {
      'fr': 'En livraison',
      'ar': 'قيد التوصيل',
      'en': 'Delivering'
    },
    'order_status_delivered': {
      'fr': 'Livrée',
      'ar': 'تم التسليم',
      'en': 'Delivered'
    },
    'order_status_cancelled': {
      'fr': 'Annulée',
      'ar': 'ملغاة',
      'en': 'Cancelled'
    },
    'upload_payment_proof': {
      'fr': 'Envoyer la capture de paiement',
      'ar': 'أرسل صورة الدفع',
      'en': 'Upload payment proof'
    },
    'payment_proof_sent': {
      'fr': 'Capture envoyée. La boutique va vérifier ton paiement.',
      'ar': 'تم الإرسال. سيتحقق المتجر من دفعتك.',
      'en': 'Sent. The shop will verify your payment.'
    },
    'no_results': {
      'fr': 'Rien à afficher pour le moment.',
      'ar': 'لا يوجد شيء لعرضه حاليا.',
      'en': 'Nothing to show yet.'
    },
    'retry': {'fr': 'Réessayer', 'ar': 'إعادة المحاولة', 'en': 'Retry'},
    'error_generic': {
      'fr': 'Une erreur est survenue.',
      'ar': 'حدث خطأ ما.',
      'en': 'Something went wrong.'
    },
    'login_with_email': {
      'fr': 'Se connecter par e-mail',
      'ar': 'الدخول بالبريد',
      'en': 'Log in with e-mail'
    },
    'contact_whatsapp': {
      'fr': 'Contacter sur WhatsApp',
      'ar': 'تواصل عبر واتساب',
      'en': 'Contact on WhatsApp'
    },
    'write_to_seller': {
      'fr': 'Écrire au vendeur',
      'ar': 'راسل البائع',
      'en': 'Write to the seller'
    },
    'shop_follow': {'fr': 'Suivre', 'ar': 'متابعة', 'en': 'Follow'},
    'shop_following': {'fr': 'Suivi(e)', 'ar': 'متابَع', 'en': 'Following'},
    'shop_followers': {'fr': 'abonnés', 'ar': 'متابعون', 'en': 'followers'},
    'shop_follower': {'fr': 'abonné', 'ar': 'متابع', 'en': 'follower'},
    'shop_edit': {
      'fr': 'Modifier ma boutique',
      'ar': 'تعديل متجري',
      'en': 'Edit my shop'
    },
    'shop_delete': {
      'fr': 'Supprimer ma boutique',
      'ar': 'حذف متجري',
      'en': 'Delete my shop'
    },
    'shop_delete_confirm_title': {
      'fr': 'Supprimer ta boutique ?',
      'ar': 'حذف متجرك؟',
      'en': 'Delete your shop?',
    },
    'shop_delete_confirm_message': {
      'fr':
          'Tous tes produits et toutes tes commandes seront supprimés aussi. Action irréversible.',
      'ar': 'سيتم حذف جميع منتجاتك وطلباتك أيضًا. هذا الإجراء نهائي.',
      'en':
          'All your products and orders will be deleted too. This cannot be undone.',
    },
    'reviews': {'fr': 'Avis', 'ar': 'التقييمات', 'en': 'Reviews'},
    'description': {'fr': 'Description', 'ar': 'الوصف', 'en': 'Description'},
    'save': {'fr': 'Enregistrer', 'ar': 'حفظ', 'en': 'Save'},
    'cancel': {'fr': 'Annuler', 'ar': 'إلغاء', 'en': 'Cancel'},
    'submit_application': {
      'fr': 'Envoyer la candidature',
      'ar': 'إرسال الطلب',
      'en': 'Submit application'
    },
    'shop_name': {
      'fr': 'Nom de la boutique',
      'ar': 'اسم المتجر',
      'en': 'Shop name'
    },
    'application_sent': {
      'fr': 'Candidature envoyée. Nous te contactons rapidement.',
      'ar': 'تم إرسال طلبك. سنتواصل معك قريبا.',
      'en': 'Application sent. We will contact you soon.'
    },
    'not_configured_title': {
      'fr': 'Configuration requise',
      'ar': 'الإعدادات مطلوبة',
      'en': 'Setup required'
    },
    'not_configured_body': {
      'fr':
          'Renseigne SUPABASE_URL et SUPABASE_ANON_KEY dans lib/app_config.dart avant de lancer l\'application.',
      'ar':
          'أدخل SUPABASE_URL و SUPABASE_ANON_KEY في lib/app_config.dart قبل التشغيل.',
      'en':
          'Set SUPABASE_URL and SUPABASE_ANON_KEY in lib/app_config.dart before running the app.'
    },
  };

  static String t(String key, String locale) {
    final entry = _t[key];
    if (entry == null) return key;
    return entry[locale] ?? entry[fallback] ?? key;
  }
}
