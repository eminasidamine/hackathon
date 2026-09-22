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
    'ok_action': {'fr': 'OK', 'ar': 'موافق', 'en': 'OK'},
    'photo_position_hint': {
      'fr': 'Ce point et ce zoom restent identiques sur les autres formats de carte.',
      'ar': 'تبقى هذه النقطة ومستوى التكبير كما هما في أشكال البطاقات الأخرى.',
      'en': 'This point and zoom stay the same across the other card formats.',
    },
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

    // Vendor activity dashboard ("My activity")
    'vendor_activity_title': {
      'fr': 'Mon activité',
      'ar': 'نشاطي',
      'en': 'My activity'
    },
    'vendor_hello': {'fr': 'Bonjour', 'ar': 'مرحبا', 'en': 'Hello'},
    'vendor_activity_subtitle': {
      'fr': 'Voici l\'activité de {shop}.',
      'ar': 'إليك نشاط {shop}.',
      'en': 'Here is {shop}\'s activity.',
    },
    'days_7': {'fr': '7 jours', 'ar': '7 أيام', 'en': '7 days'},
    'days_30': {'fr': '30 jours', 'ar': '30 يومًا', 'en': '30 days'},
    'days_90': {'fr': '90 jours', 'ar': '90 يومًا', 'en': '90 days'},
    'kpi_revenue': {
      'fr': 'Chiffre d\'affaires',
      'ar': 'الإيرادات',
      'en': 'Revenue'
    },
    'kpi_orders': {'fr': 'Commandes', 'ar': 'الطلبات', 'en': 'Orders'},
    'kpi_customers': {'fr': 'Clients', 'ar': 'العملاء', 'en': 'Customers'},
    'kpi_growth': {'fr': 'Croissance', 'ar': 'النمو', 'en': 'Growth'},
    'kpi_growth_first_period': {
      'fr': 'Croissance (1ère période)',
      'ar': 'النمو (الفترة الأولى)',
      'en': 'Growth (first period)',
    },
    'block_sales_title': {'fr': 'Ventes', 'ar': 'المبيعات', 'en': 'Sales'},
    'block_sales_subtitle': {
      'fr': 'Chiffre d\'affaires jour par jour',
      'ar': 'الإيرادات يومًا بيوم',
      'en': 'Revenue day by day',
    },
    'chart_not_enough_days': {
      'fr': 'Pas encore assez de jours pour tracer un graphique.',
      'ar': 'لا توجد أيام كافية بعد لرسم مخطط.',
      'en': 'Not enough days yet to draw a chart.',
    },
    'chart_peak': {'fr': 'Pic : {x}', 'ar': 'الذروة: {x}', 'en': 'Peak: {x}'},
    'block_payments_title': {
      'fr': 'Paiements',
      'ar': 'المدفوعات',
      'en': 'Payments'
    },
    'block_payments_subtitle': {
      'fr': 'Répartition par service de paiement',
      'ar': 'التوزيع حسب خدمة الدفع',
      'en': 'Breakdown by payment service',
    },
    'payment_provider_other': {'fr': 'Autre', 'ar': 'أخرى', 'en': 'Other'},
    'no_payments_period': {
      'fr': 'Aucun paiement sur la période.',
      'ar': 'لا مدفوعات خلال هذه الفترة.',
      'en': 'No payments over the period.',
    },
    'refs_pending_singular': {
      'fr': '{n} référence en attente de vérification.',
      'ar': 'مرجع واحد في انتظار التحقق.',
      'en': '{n} reference pending verification.',
    },
    'refs_pending_plural': {
      'fr': '{n} références en attente de vérification.',
      'ar': '{n} مراجع في انتظار التحقق.',
      'en': '{n} references pending verification.',
    },
    'block_products_title': {
      'fr': 'Produits',
      'ar': 'المنتجات',
      'en': 'Products'
    },
    'block_products_subtitle': {
      'fr': 'Vos meilleures ventes sur la période',
      'ar': 'أفضل منتجاتك مبيعًا خلال الفترة',
      'en': 'Your best sellers over the period',
    },
    'no_products_sold_period': {
      'fr': 'Aucun produit vendu sur la période.',
      'ar': 'لم يُباع أي منتج خلال هذه الفترة.',
      'en': 'No products sold over the period.',
    },
    'readiness_title': {
      'fr': 'Préparation financière',
      'ar': 'الجاهزية المالية',
      'en': 'Financial readiness',
    },
    'readiness_subtitle': {
      'fr': 'Un indicateur d\'activité, pas un score de crédit',
      'ar': 'مؤشر نشاط، وليس درجة ائتمانية',
      'en': 'An activity indicator, not a credit score',
    },
    'readiness_disclaimer': {
      'fr': 'Cet indicateur résume votre activité sur cette application. Ce '
          'n\'est ni une décision de crédit, ni une garantie de financement. '
          'Il peut aider un partenaire financier à mieux comprendre une '
          'activité autrement difficile à évaluer.',
      'ar': 'يلخّص هذا المؤشر نشاطك على هذا التطبيق. إنه ليس قرار ائتمان ولا '
          'ضمان تمويل. يمكن أن يساعد شريكًا ماليًا على فهم نشاط تجاري يصعب '
          'تقييمه بطريقة أخرى.',
      'en': 'This indicator summarizes your activity on this app. It is not a '
          'credit decision or a financing guarantee. It can help a '
          'financial partner better understand a business that is '
          'otherwise hard to assess.',
    },
    'readiness_label_activity_regularity': {
      'fr': 'Régularité de l\'activité',
      'ar': 'انتظام النشاط',
      'en': 'Activity regularity',
    },
    'readiness_label_order_volume': {
      'fr': 'Volume de commandes',
      'ar': 'حجم الطلبات',
      'en': 'Order volume',
    },
    'readiness_label_digital_payments': {
      'fr': 'Paiements numériques confirmés',
      'ar': 'المدفوعات الرقمية المؤكدة',
      'en': 'Confirmed digital payments',
    },
    'readiness_label_shop_profile': {
      'fr': 'Profil de la boutique',
      'ar': 'ملف المتجر',
      'en': 'Shop profile',
    },
    'readiness_weeks_singular': {
      'fr': '{active} semaine avec au moins une vente sur {total}',
      'ar': 'أسبوع واحد فيه بيع واحد على الأقل من أصل {total}',
      'en': '{active} week with at least one sale out of {total}',
    },
    'readiness_weeks_plural': {
      'fr': '{active} semaines avec au moins une vente sur {total}',
      'ar': '{active} أسابيع فيها بيع واحد على الأقل من أصل {total}',
      'en': '{active} weeks with at least one sale out of {total}',
    },
    'readiness_orders_singular': {
      'fr': '{n} commande sur la période (référence : {target})',
      'ar': 'طلب واحد خلال الفترة (المرجع: {target})',
      'en': '{n} order over the period (reference: {target})',
    },
    'readiness_orders_plural': {
      'fr': '{n} commandes sur la période (référence : {target})',
      'ar': '{n} طلبات خلال الفترة (المرجع: {target})',
      'en': '{n} orders over the period (reference: {target})',
    },
    'readiness_payments_singular': {
      'fr': '{n} paiement trouvé dans l\'historique bancaire sur {total}',
      'ar': 'دفعة واحدة موجودة في السجل المصرفي من أصل {total}',
      'en': '{n} payment found in banking history out of {total}',
    },
    'readiness_payments_plural': {
      'fr': '{n} paiements trouvés dans l\'historique bancaire sur {total}',
      'ar': '{n} مدفوعات موجودة في السجل المصرفي من أصل {total}',
      'en': '{n} payments found in banking history out of {total}',
    },
    'readiness_fields_singular': {
      'fr': '{n} champ renseigné sur {total}',
      'ar': 'حقل واحد معبأ من أصل {total}',
      'en': '{n} field filled out of {total}',
    },
    'readiness_fields_plural': {
      'fr': '{n} champs renseignés sur {total}',
      'ar': '{n} حقول معبأة من أصل {total}',
      'en': '{n} fields filled out of {total}',
    },
    'block_insights_title': {
      'fr': 'Analyse',
      'ar': 'التحليل',
      'en': 'Insights'
    },
    'block_insights_subtitle': {
      'fr': 'Une lecture automatique de vos chiffres',
      'ar': 'قراءة تلقائية لأرقامك',
      'en': 'An automatic read of your numbers',
    },
    'insight_suggestion_prefix': {
      'fr': 'Suggestion — ',
      'ar': 'اقتراح — ',
      'en': 'Suggestion — ',
    },
    'insight_observation_prefix': {
      'fr': 'Constat — ',
      'ar': 'ملاحظة — ',
      'en': 'Observation — ',
    },
    'insights_footer': {
      'fr': 'Ces lignes sont calculées à partir de vos commandes. Aucune '
          'donnée n\'est envoyée à un service externe.',
      'ar': 'يتم احتساب هذه الأسطر من طلباتك. لا يتم إرسال أي بيانات إلى خدمة '
          'خارجية.',
      'en': 'These lines are computed from your orders. No data is sent to '
          'an external service.',
    },
    'generate_business_profile': {
      'fr': 'Générer mon profil d\'entreprise',
      'ar': 'إنشاء ملفي التجاري',
      'en': 'Generate my business profile',
    },
    'no_sales_yet_title': {
      'fr': 'Aucune vente pour l\'instant',
      'ar': 'لا مبيعات بعد',
      'en': 'No sales yet'
    },
    'no_sales_yet_subtitle': {
      'fr': 'Partagez votre boutique pour recevoir vos premières commandes. '
          'Vos statistiques apparaîtront ici automatiquement.',
      'ar': 'شارك متجرك لتصلك أول طلباتك. ستظهر إحصائياتك هنا تلقائيًا.',
      'en': 'Share your shop to receive your first orders. Your stats will '
          'show up here automatically.',
    },
    'dashboard_load_error_title': {
      'fr': 'Impossible de charger vos données',
      'ar': 'تعذر تحميل بياناتك',
      'en': 'Could not load your data',
    },
    'check_connection_retry': {
      'fr': 'Vérifiez votre connexion et réessayez.',
      'ar': 'تحقق من اتصالك وأعد المحاولة.',
      'en': 'Check your connection and try again.',
    },

    // Insights (auto-generated sentences)
    'insight_sales_grew': {
      'fr':
          'Vos ventes ont augmenté de {n}% par rapport aux {days} jours précédents.',
      'ar': 'ارتفعت مبيعاتك بنسبة {n}% مقارنة بالأيام الـ{days} السابقة.',
      'en': 'Your sales grew {n}% compared to the previous {days} days.',
    },
    'insight_sales_dropped': {
      'fr':
          'Vos ventes ont baissé de {n}% par rapport aux {days} jours précédents.',
      'ar': 'انخفضت مبيعاتك بنسبة {n}% مقارنة بالأيام الـ{days} السابقة.',
      'en': 'Your sales dropped {n}% compared to the previous {days} days.',
    },
    'insight_busiest_day': {
      'fr': 'Votre jour le plus actif est {day}.',
      'ar': 'يومك الأكثر نشاطًا هو {day}.',
      'en': 'Your busiest day is {day}.',
    },
    'insight_restock_suggestion': {
      'fr': 'Pensez à réapprovisionner avant {day}.',
      'ar': 'فكّر في إعادة التموين قبل {day}.',
      'en': 'Consider restocking before {day}.',
    },
    'insight_best_seller': {
      'fr': 'Votre meilleure vente est « {name} ».',
      'ar': 'أفضل منتج مبيعًا لديك هو "{name}".',
      'en': 'Your best seller is "{name}".',
    },
    'insight_provider_share': {
      'fr': '{pct}% de vos paiements passent par {provider}.',
      'ar': '{pct}% من مدفوعاتك تمر عبر {provider}.',
      'en': '{pct}% of your payments go through {provider}.',
    },
    'insight_refs_checking_singular': {
      'fr':
          '{n} référence de paiement reste à vérifier dans votre appli bancaire.',
      'ar': 'يتبقى مرجع دفع واحد للتحقق منه في تطبيقك المصرفي.',
      'en': '{n} payment reference still needs checking in your banking app.',
    },
    'insight_refs_checking_plural': {
      'fr':
          '{n} références de paiement restent à vérifier dans votre appli bancaire.',
      'ar': 'يتبقى {n} مراجع دفع للتحقق منها في تطبيقك المصرفي.',
      'en': '{n} payment references still need checking in your banking app.',
    },
    'insight_repeat_customers': {
      'fr': 'Vos clients commandent {x} fois en moyenne : les clients fidèles '
          'font déjà tourner votre activité.',
      'ar': 'يطلب عملاؤك {x} مرة في المتوسط: العملاء المتكررون يقودون نشاطك '
          'التجاري بالفعل.',
      'en': 'Your customers order {x} times on average: repeat customers '
          'already drive your business.',
    },
    'weekday_monday': {'fr': 'lundi', 'ar': 'الإثنين', 'en': 'Monday'},
    'weekday_tuesday': {'fr': 'mardi', 'ar': 'الثلاثاء', 'en': 'Tuesday'},
    'weekday_wednesday': {
      'fr': 'mercredi',
      'ar': 'الأربعاء',
      'en': 'Wednesday'
    },
    'weekday_thursday': {'fr': 'jeudi', 'ar': 'الخميس', 'en': 'Thursday'},
    'weekday_friday': {'fr': 'vendredi', 'ar': 'الجمعة', 'en': 'Friday'},
    'weekday_saturday': {'fr': 'samedi', 'ar': 'السبت', 'en': 'Saturday'},
    'weekday_sunday': {'fr': 'dimanche', 'ar': 'الأحد', 'en': 'Sunday'},
    'month_1': {'fr': 'janvier', 'ar': 'يناير', 'en': 'January'},
    'month_2': {'fr': 'février', 'ar': 'فبراير', 'en': 'February'},
    'month_3': {'fr': 'mars', 'ar': 'مارس', 'en': 'March'},
    'month_4': {'fr': 'avril', 'ar': 'أبريل', 'en': 'April'},
    'month_5': {'fr': 'mai', 'ar': 'مايو', 'en': 'May'},
    'month_6': {'fr': 'juin', 'ar': 'يونيو', 'en': 'June'},
    'month_7': {'fr': 'juillet', 'ar': 'يوليو', 'en': 'July'},
    'month_8': {'fr': 'août', 'ar': 'أغسطس', 'en': 'August'},
    'month_9': {'fr': 'septembre', 'ar': 'سبتمبر', 'en': 'September'},
    'month_10': {'fr': 'octobre', 'ar': 'أكتوبر', 'en': 'October'},
    'month_11': {'fr': 'novembre', 'ar': 'نوفمبر', 'en': 'November'},
    'month_12': {'fr': 'décembre', 'ar': 'ديسمبر', 'en': 'December'},

    // Business profile screen
    'business_profile_title': {
      'fr': 'Mon profil d\'entreprise',
      'ar': 'ملفي التجاري',
      'en': 'My business profile',
    },
    'could_not_generate_file': {
      'fr': 'Impossible de générer le fichier. {e}',
      'ar': 'تعذر إنشاء الملف. {e}',
      'en': 'Could not generate the file. {e}',
    },
    'business_profile_disclaimer': {
      'fr': 'Ce fichier résume l\'activité d\'une entreprise telle qu\'enregistrée '
          'dans cette application. Ce n\'est ni une décision de crédit, ni une '
          'garantie de financement, ni une évaluation par un établissement '
          'financier. Les chiffres sont calculés à partir des commandes '
          'réelles de la boutique.',
      'ar': 'يلخّص هذا الملف نشاط الشركة كما هو مسجل في هذا التطبيق. إنه ليس '
          'قرار ائتمان، ولا ضمان تمويل، ولا تقييمًا من مؤسسة مالية. تُحتسب '
          'الأرقام من طلبات المتجر الحقيقية.',
      'en': 'This file summarizes a business\'s activity as recorded in this app. '
          'It is not a credit decision, a financing guarantee, or an assessment '
          'by a financial institution. Figures are computed from the shop\'s '
          'real orders.',
    },
    'business_profile_label': {
      'fr': 'PROFIL D\'ENTREPRISE',
      'ar': 'ملف تجاري',
      'en': 'BUSINESS PROFILE',
    },
    'active_since': {
      'fr': 'Actif depuis {date}',
      'ar': 'نشط منذ {date}',
      'en': 'Active since {date}',
    },
    'marketplace_history_title': {
      'fr': 'Historique sur la marketplace',
      'ar': 'سجل النشاط في السوق',
      'en': 'Marketplace history',
    },
    'orders_fulfilled': {
      'fr': 'Commandes honorées',
      'ar': 'الطلبات المنفذة',
      'en': 'Orders fulfilled',
    },
    'sales_volume': {
      'fr': 'Volume des ventes',
      'ar': 'حجم المبيعات',
      'en': 'Sales volume'
    },
    'avg_order_value': {
      'fr': 'Panier moyen',
      'ar': 'متوسط قيمة الطلب',
      'en': 'Average order value',
    },
    'distinct_customers': {
      'fr': 'Clients distincts',
      'ar': 'عملاء مختلفون',
      'en': 'Distinct customers',
    },
    'orders_per_customer': {
      'fr': 'Commandes par client',
      'ar': 'الطلبات لكل عميل',
      'en': 'Orders per customer',
    },
    'digital_payments_label': {
      'fr': 'PAIEMENTS NUMÉRIQUES',
      'ar': 'المدفوعات الرقمية',
      'en': 'DIGITAL PAYMENTS',
    },
    'payments_found_in_history': {
      'fr': '{n} paiement(s) sur {total} trouvé(s) dans l\'historique bancaire '
          'du commerçant.',
      'ar': '{n} من أصل {total} مدفوعات موجودة في السجل المصرفي للتاجر.',
      'en': '{n} payment(s) out of {total} found in the merchant\'s banking '
          'history.',
    },
    'no_payments_recorded': {
      'fr': 'Aucun paiement enregistré.',
      'ar': 'لا مدفوعات مسجلة.',
      'en': 'No payments recorded.',
    },
    'no_profile_yet_title': {
      'fr': 'Pas encore de profil',
      'ar': 'لا يوجد ملف بعد',
      'en': 'No profile yet'
    },
    'no_profile_yet_subtitle': {
      'fr':
          'Votre profil d\'entreprise se construit à partir de vos ventes. Il '
              'apparaîtra dès votre première commande.',
      'ar': 'يُبنى ملفك التجاري من مبيعاتك. سيظهر بمجرد استلام أول طلب.',
      'en': 'Your business profile builds itself from your sales. It will '
          'appear as soon as you get your first order.',
    },
    'could_not_load_business_profile': {
      'fr': 'Impossible de charger votre profil d\'entreprise',
      'ar': 'تعذر تحميل ملفك التجاري',
      'en': 'Could not load your business profile',
    },
    'generating_ellipsis': {
      'fr': 'Génération…',
      'ar': 'جارٍ الإنشاء…',
      'en': 'Generating…'
    },
    'download_profile_pdf': {
      'fr': 'Télécharger mon profil (PDF)',
      'ar': 'تحميل ملفي (PDF)',
      'en': 'Download my profile (PDF)',
    },
    'share_control_note': {
      'fr':
          'Vous choisissez à qui l\'envoyer. Rien n\'est partagé automatiquement.',
      'ar': 'أنت من يختار لمن يرسله. لا شيء يُشارك تلقائيًا.',
      'en': 'You choose who you send it to. Nothing is shared automatically.',
    },

    // Vendor: payment status on an order
    'activity_entry_subtitle': {
      'fr': 'Ventes, paiements et préparation financière',
      'ar': 'المبيعات والمدفوعات والجاهزية المالية',
      'en': 'Sales, payments and financial readiness',
    },
    'amount_received_title': {
      'fr': 'Montant reçu',
      'ar': 'المبلغ المستلم',
      'en': 'Amount received',
    },
    'amount_received_prompt': {
      'fr': 'Combien avez-vous réellement reçu pour cette commande ? Le total '
          'attendu est {total}.',
      'ar':
          'كم استلمت فعليًا مقابل هذا الطلب؟ المبلغ الإجمالي المتوقع هو {total}.',
      'en': 'How much did you actually receive for this order? The expected '
          'total is {total}.',
    },
    'confirm': {'fr': 'Confirmer', 'ar': 'تأكيد', 'en': 'Confirm'},
    'payment_status_label': {
      'fr': 'Statut du paiement',
      'ar': 'حالة الدفع',
      'en': 'Payment status',
    },
    'payment_verified_label': {
      'fr': 'Vérifié',
      'ar': 'تم التحقق',
      'en': 'Verified',
    },
    'payment_verified_amount': {
      'fr': ' — {x} reçu',
      'ar': ' — تم استلام {x}',
      'en': ' — {x} received',
    },
    'payment_rejected_label': {
      'fr': 'Référence introuvable',
      'ar': 'المرجع غير موجود',
      'en': 'Reference not found',
    },
    'payment_submitted_label': {
      'fr': 'Envoyé — en attente de vérification',
      'ar': 'مُرسل — في انتظار التحقق',
      'en': 'Submitted — pending verification',
    },
    'verify_action': {'fr': 'Vérifier', 'ar': 'تحقق', 'en': 'Verify'},
    'reject_action': {'fr': 'Rejeter', 'ar': 'رفض', 'en': 'Reject'},
    'code_copied': {
      'fr': 'Code copié.',
      'ar': 'تم نسخ الرمز.',
      'en': 'Code copied.'
    },
    'delivery_label': {'fr': 'Livraison', 'ar': 'التوصيل', 'en': 'Delivery'},
    'no_location_shared': {
      'fr': 'Aucune localisation partagée.',
      'ar': 'لم تتم مشاركة أي موقع.',
      'en': 'No location shared.',
    },
    'copy_tooltip': {'fr': 'Copier', 'ar': 'نسخ', 'en': 'Copy'},
    'open_in_google_maps': {
      'fr': 'Ouvrir dans Google Maps',
      'ar': 'فتح في خرائط جوجل',
      'en': 'Open in Google Maps',
    },
    'payment_screenshot_old_order': {
      'fr': 'Capture de paiement (ancienne commande)',
      'ar': 'لقطة شاشة الدفع (طلب قديم)',
      'en': 'Payment screenshot (old order)',
    },
    'view_screenshot': {
      'fr': 'Voir la capture',
      'ar': 'عرض اللقطة',
      'en': 'View screenshot',
    },
    'image_not_found': {
      'fr': 'Image introuvable.',
      'ar': 'الصورة غير موجودة.',
      'en': 'Image not found.',
    },

    // Login form validation
    'validation_email_required': {
      'fr': 'Merci de saisir votre email.',
      'ar': 'يرجى إدخال بريدك الإلكتروني.',
      'en': 'Please enter your email.',
    },
    'validation_email_invalid': {
      'fr': 'Merci de saisir une adresse email valide.',
      'ar': 'يرجى إدخال بريد إلكتروني صالح.',
      'en': 'Please enter a valid email address.',
    },
    'validation_password_required': {
      'fr': 'Merci de saisir votre mot de passe.',
      'ar': 'يرجى إدخال كلمة المرور.',
      'en': 'Please enter your password.',
    },
    'validation_password_length': {
      'fr': 'Le mot de passe doit contenir au moins 6 caractères.',
      'ar': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.',
      'en': 'Password must be at least 6 characters.',
    },
    'validation_name_required': {
      'fr': 'Merci de saisir votre nom.',
      'ar': 'يرجى إدخال اسمك.',
      'en': 'Please enter your name.',
    },
    'validation_phone_required': {
      'fr': 'Merci de saisir votre numéro de téléphone.',
      'ar': 'يرجى إدخال رقم هاتفك.',
      'en': 'Please enter your phone number.',
    },

    // Shared error messages
    'error_no_permission': {
      'fr':
          'Vous n\'avez pas les droits nécessaires pour cette action avec ce type de compte.',
      'ar': 'ليست لديك الصلاحيات اللازمة لهذا الإجراء بهذا النوع من الحسابات.',
      'en': 'You don\'t have the rights to do this with your account type.',
    },
    'checkout_phone_required': {
      'fr': 'Le numéro de téléphone est requis.',
      'ar': 'رقم الهاتف مطلوب.',
      'en': 'Phone number is required.',
    },
    'checkout_share_location_or_address': {
      'fr': 'Partagez votre position, ou saisissez votre adresse manuellement.',
      'ar': 'شارك موقعك، أو أدخل عنوانك يدويًا.',
      'en': 'Share your location, or type your address by hand.',
    },
    'checkout_enter_payment_reference': {
      'fr':
          'Saisissez la référence de paiement de votre banque pour chaque boutique.',
      'ar': 'أدخل مرجع الدفع من بنكك لكل متجر.',
      'en': 'Enter the payment reference from your bank for each shop.',
    },
    'checkout_reference_already_used': {
      'fr':
          'Cette référence de paiement a déjà été utilisée pour une autre commande.',
      'ar': 'تم استخدام مرجع الدفع هذا لطلب آخر بالفعل.',
      'en': 'This payment reference has already been used for another order.',
    },
    // Driver space
    'delivery_space_title': {
      'fr': 'Espace livraison',
      'ar': 'مساحة التوصيل',
      'en': 'Delivery space',
    },
    'tab_available': {'fr': 'Disponibles', 'ar': 'متاحة', 'en': 'Available'},
    'tab_my_deliveries': {
      'fr': 'Mes livraisons',
      'ar': 'توصيلاتي',
      'en': 'My deliveries',
    },
    'driver_online_status': {
      'fr': 'Vous êtes en ligne — visible pour les nouvelles livraisons',
      'ar': 'أنت متصل — مرئي للتوصيلات الجديدة',
      'en': "You're online — visible for new deliveries",
    },
    'driver_offline_status': {
      'fr':
          'Vous êtes hors ligne — aucune nouvelle livraison ne vous parviendra',
      'ar': 'أنت غير متصل — لن تصلك أي توصيلات جديدة',
      'en': "You're offline — no new deliveries will reach you",
    },
    'no_deliveries_waiting_title': {
      'fr': 'Aucune livraison en attente',
      'ar': 'لا توجد توصيلات في الانتظار',
      'en': 'No deliveries waiting',
    },
    'no_deliveries_waiting_subtitle': {
      'fr':
          'Les nouvelles demandes apparaîtront ici dès qu\'un client commande une livraison.',
      'ar': 'ستظهر الطلبات الجديدة هنا بمجرد أن يطلب عميل توصيلاً.',
      'en':
          'New requests will appear here the moment a customer orders delivery.',
    },
    'no_deliveries_yet_title': {
      'fr': 'Aucune livraison pour l\'instant',
      'ar': 'لا توصيلات بعد',
      'en': 'No deliveries yet',
    },
    'no_deliveries_yet_subtitle': {
      'fr': 'Les livraisons que vous acceptez apparaîtront ici.',
      'ar': 'ستظهر هنا التوصيلات التي تقبلها.',
      'en': 'Deliveries you accept will show up here.',
    },
    'delivery_accepted_snackbar': {
      'fr':
          'Livraison acceptée — voir « Mes livraisons » pour le contact du client.',
      'ar':
          'تم قبول التوصيل — راجع "توصيلاتي" لمعرفة معلومات التواصل مع العميل.',
      'en':
          'Delivery accepted — check "My deliveries" for the customer contact.',
    },
    'cancel_delivery_confirm_title': {
      'fr': 'Annuler cette livraison ?',
      'ar': 'إلغاء هذا التوصيل؟',
      'en': 'Cancel this delivery?',
    },
    'cancel_delivery_confirm_body': {
      'fr':
          'Elle retournera sur le tableau pour qu\'un autre livreur puisse l\'accepter.',
      'ar': 'ستعود إلى اللوحة ليقبلها سائق آخر.',
      'en': 'It will go back to the board for another driver to accept.',
    },
    'keep_it': {'fr': 'Garder', 'ar': 'الاحتفاظ بها', 'en': 'Keep it'},
    'cancel_delivery_action': {
      'fr': 'Annuler la livraison',
      'ar': 'إلغاء التوصيل',
      'en': 'Cancel delivery',
    },
    'application_not_approved_title': {
      'fr': 'Candidature non approuvée',
      'ar': 'لم تتم الموافقة على الطلب',
      'en': 'Application not approved',
    },
    'application_under_review_title': {
      'fr': 'Candidature en cours d\'examen',
      'ar': 'الطلب قيد المراجعة',
      'en': 'Application under review',
    },
    'application_not_approved_body': {
      'fr':
          'Votre candidature de livreur n\'a pas été approuvée. Contactez-nous '
              'si vous pensez qu\'il s\'agit d\'une erreur.',
      'ar':
          'لم تتم الموافقة على طلبك كسائق. تواصل معنا إذا كنت تعتقد أن هذا خطأ.',
      'en':
          "Your driver application wasn't approved. Contact us if you think this is a mistake.",
    },
    'application_under_review_body': {
      'fr':
          'Nous examinons votre candidature de livreur. Vous pourrez accepter '
              'des livraisons dès qu\'elle sera approuvée.',
      'ar': 'نراجع طلبك كسائق. ستتمكن من قبول التوصيلات بمجرد الموافقة عليه.',
      'en':
          "We're reviewing your driver application. You'll be able to accept deliveries once it's approved.",
    },
    'shop_fallback_label': {'fr': 'Boutique', 'ar': 'متجر', 'en': 'Shop'},
    'distance_unknown': {
      'fr': 'Distance inconnue',
      'ar': 'المسافة غير معروفة',
      'en': 'Distance unknown',
    },
    'accept_action': {'fr': 'Accepter', 'ar': 'قبول', 'en': 'Accept'},
    'contact_action': {'fr': 'Contacter', 'ar': 'اتصال', 'en': 'Contact'},
    'delivered_action': {'fr': 'Livré', 'ar': 'تم التسليم', 'en': 'Delivered'},
    'delivery_point_title': {
      'fr': 'Point de livraison',
      'ar': 'نقطة التوصيل',
      'en': 'Delivery point',
    },
    'open_in_maps': {
      'fr': 'Ouvrir dans Maps',
      'ar': 'فتح في الخرائط',
      'en': 'Open in Maps',
    },
    'customer_contact_title': {
      'fr': 'Contact client',
      'ar': 'معلومات التواصل مع العميل',
      'en': 'Customer contact',
    },
    'visible_because_accepted': {
      'fr': 'Visible car vous avez accepté cette livraison.',
      'ar': 'مرئي لأنك قبلت هذا التوصيل.',
      'en': 'Visible because you accepted this delivery.',
    },
    'call_action': {'fr': 'Appeler', 'ar': 'اتصال', 'en': 'Call'},
    'whatsapp_action': {'fr': 'WhatsApp', 'ar': 'واتساب', 'en': 'WhatsApp'},
    'deliver_with_us_title': {
      'fr': 'Livrez avec nous',
      'ar': 'وصّل معنا',
      'en': 'Deliver with us',
    },
    'deliver_with_us_subtitle': {
      'fr': 'Récupérez des commandes chez des boutiques proches et soyez payé '
          'pour la livraison. Connectez-vous ou créez un compte pour continuer.',
      'ar':
          'استلم الطلبات من المتاجر القريبة واحصل على أجر مقابل التوصيل. سجّل '
              'الدخول أو أنشئ حسابًا للمتابعة.',
      'en': 'Pick up orders from shops nearby and get paid for the delivery. '
          'Log in or create an account to continue.',
    },
    'vehicle_label': {'fr': 'Véhicule', 'ar': 'المركبة', 'en': 'Vehicle'},
    'vehicle_motorcycle': {
      'fr': 'Moto',
      'ar': 'دراجة نارية',
      'en': 'Motorcycle'
    },
    'vehicle_car': {'fr': 'Voiture', 'ar': 'سيارة', 'en': 'Car'},
    'start_delivering_action': {
      'fr': 'COMMENCER À LIVRER',
      'ar': 'ابدأ التوصيل',
      'en': 'START DELIVERING',
    },
    // Business profile PDF
    'pdf_city_label': {'fr': 'Ville', 'ar': 'المدينة', 'en': 'City'},
    'pdf_active_since_label': {
      'fr': 'Actif depuis',
      'ar': 'نشط منذ',
      'en': 'Active since',
    },
    'pdf_payment_service_label': {
      'fr': 'Service de paiement',
      'ar': 'خدمة الدفع',
      'en': 'Payment service',
    },
    'pdf_generated_on_label': {
      'fr': 'Généré le',
      'ar': 'أُنشئ في',
      'en': 'Generated on',
    },
    'pdf_page_label': {'fr': 'page', 'ar': 'صفحة', 'en': 'page'},
    'pdf_no_mismatch': {
      'fr': 'Aucun écart entre les montants reçus et les totaux des commandes.',
      'ar': 'لا يوجد فرق بين المبالغ المستلمة وإجماليات الطلبات.',
      'en': 'No mismatch between amounts received and order totals.',
    },
    'pdf_mismatch_singular': {
      'fr':
          '{n} commande présente un écart entre le montant reçu et le montant dû.',
      'ar': 'طلب واحد يُظهر فرقًا بين المبلغ المستلم والمبلغ المستحق.',
      'en':
          '{n} order shows a mismatch between the amount received and the amount due.',
    },
    'pdf_mismatch_plural': {
      'fr':
          '{n} commandes présentent un écart entre le montant reçu et le montant dû.',
      'ar': '{n} طلبات تُظهر فرقًا بين المبلغ المستلم والمبلغ المستحق.',
      'en':
          '{n} orders show a mismatch between the amount received and the amount due.',
    },
    'error_generic_short': {
      'fr': 'Une erreur est survenue. Veuillez réessayer.',
      'ar': 'حدث خطأ. يرجى المحاولة مرة أخرى.',
      'en': 'Something went wrong. Please try again.',
    },
  };

  static String t(String key, String locale) {
    final entry = _t[key];
    if (entry == null) return key;
    return entry[locale] ?? entry[fallback] ?? key;
  }
}
