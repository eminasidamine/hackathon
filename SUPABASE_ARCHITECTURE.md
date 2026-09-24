# Architecture Supabase — Boutigui

## Vue d'ensemble

Backend **Supabase** (PostgreSQL managé) : base de données relationnelle, authentification, stockage de fichiers, sécurité au niveau ligne (RLS), fonctions PL/pgSQL, et un canal temps réel pour les livraisons. Aucun serveur applicatif custom — l'app Flutter parle directement à Supabase via son SDK, et la sécurité est entièrement portée par PostgreSQL (RLS + fonctions `security definer`), pas par du code côté client.

```
┌─────────────────────────────┐
│   App Flutter (web/mobile)   │  client, vendeur, livreur, admin
└───────────────┬───────────────┘
                │  supabase_flutter (REST + Realtime)
┌───────────────▼───────────────┐
│           Supabase             │
│  ┌───────────┐ ┌─────────────┐ │
│  │ PostgreSQL │ │ Auth         │ │
│  │  + RLS     │ │ (email/pwd)  │ │
│  └───────────┘ └─────────────┘ │
│  ┌───────────┐ ┌─────────────┐ │
│  │ Storage    │ │ Realtime     │ │
│  │ (6 buckets)│ │ (livraisons) │ │
│  └───────────┘ └─────────────┘ │
└─────────────────────────────────┘
```

## Rôles et authentification

Un seul système d'authentification Supabase (`auth.users`) pour tout le monde — client, vendeur, livreur, admin ne sont pas des comptes différents, ce sont des **rôles** sur le même compte :

- `profiles.role` : `client` (défaut) / `vendor` / `admin`.
- Le statut livreur est séparé : une ligne dans `driver_profiles` (présence = candidature livreur), avec son propre `status` (`pending` / `approved` / `rejected`).
- Un trigger (`handle_new_user`) crée automatiquement la ligne `profiles` à l'inscription, à partir de `auth.users`.
- Un trigger (`prevent_self_role_change`) empêche un utilisateur de modifier son propre `role` depuis l'app — le seul moyen de devenir admin est une commande SQL manuelle dans le SQL Editor.

## Tables

### Cœur marketplace

| Table | Rôle |
|---|---|
| `profiles` | Un profil par utilisateur Supabase Auth. Rôle, coordonnées, ville. |
| `shops` | Boutiques. Visibilité (`is_visible`) activable **uniquement par un admin** (trigger `prevent_self_shop_activation`). Code marchand et fournisseur de paiement, position GPS pour la livraison. |
| `categories` | Catégories à plat (avec `parent_id` pour une hiérarchie), genre (`women`/`men`/`*`), image avec cadrage personnalisé. |
| `products` | Produits d'une boutique. Prix, stock, prix barré, variantes (taille **ou** couleur), catégorie. |
| `product_images` | Photos d'un produit, ordonnées, chacune avec son propre point de cadrage et zoom. |
| `favorite_products` / `favorite_shops` | Favoris, clé composite `(user_id, product_id/shop_id)`. |
| `orders` | Commandes. Une commande = une boutique (un panier multi-boutiques crée plusieurs commandes). Statut de la commande **et** statut du paiement suivis séparément. |
| `order_items` | Lignes d'une commande (produit, quantité, prix figé au moment de la commande). |
| `reviews` | Avis produit, liés à une commande réelle (achat requis pour laisser un avis). |
| `shop_visit_daily` | Compteur de visites d'une boutique par jour, incrémenté via la fonction `record_shop_visit`. |
| `vendor_applications` | Candidatures "devenir vendeur", validées par un admin. |

### Livraison

| Table | Rôle |
|---|---|
| `driver_profiles` | Statut livreur (`pending`/`approved`/`rejected`), type de véhicule, disponibilité. |
| `delivery_requests` | Une livraison par commande (`unique(order_id)`). Distance calculée automatiquement par trigger (formule de Haversine) à partir des coordonnées GPS du point de retrait et de dépôt. |

### Contenu et back-office admin

| Table | Rôle |
|---|---|
| `home_banners` | Bannières carrousel de la page d'accueil. |
| `home_collections` | Blocs "vitrine" de la page d'accueil (bannière + produits d'une catégorie ou mixés). |
| `notifications` | Notifications applicatives par utilisateur. |
| `app_settings` | Réglages globaux (téléphone de contact, site web) — une seule ligne. |

## Row Level Security (RLS)

Chaque table a RLS activé — **aucune donnée n'est accessible sans policy explicite**. Le principe général :

- **Lecture publique** pour tout ce qui doit être visible sans compte (catégories, produits/boutiques visibles).
- **Écriture réservée au propriétaire** : un vendeur ne modifie que ses propres boutiques/produits (`owns_shop()`, `owns_product_shop()`), un client ne voit que ses propres commandes/favoris, un livreur n'accepte que des livraisons qui lui sont assignées.
- **Admin transverse** : `is_admin()` passe outre la plupart des restrictions en lecture et écriture.

Fonctions utilitaires (toutes `security definer`, réutilisées dans la majorité des policies) :

- `current_role()`, `is_admin()` — rôle de l'utilisateur courant.
- `owns_shop(shop_id)`, `owns_product_shop(product_id)` — vérifie la propriété sans exposer la table `shops` à la policy appelante.

### Règles anti-conflit d'intérêt

Deux règles métier appliquées **au niveau base de données**, pas seulement dans l'app :

- `orders_insert_client` : `client_id = auth.uid() and not owns_shop(shop_id)` — un vendeur ne peut pas commander dans sa propre boutique.
- `accept_delivery_request()` : lève une exception si le livreur qui accepte est aussi le client de la commande — un livreur ne peut pas accepter sa propre livraison.

### Verrou sur les commandes déjà passées

`restrict_client_order_update()` (trigger `before update` sur `orders`) empêche un client de modifier une commande après coup (montant, référence de paiement, etc.) — seule l'annulation d'une commande encore `pending` est autorisée. Les fonctions livreur (`accept_delivery_request`, `mark_delivery_delivered`, `release_delivery_request`) doivent modifier `orders.status` en leur nom : elles lèvent un drapeau de transaction (`app.bypass_order_guard`) juste avant, que le trigger reconnaît et laisse passer.

## Fonctions RPC principales

| Fonction | Usage |
|---|---|
| `record_shop_visit(shop_id)` | Incrémente le compteur de visite du jour. |
| `accept_delivery_request(request_id)` | Un livreur approuvé accepte une livraison en attente (statut commande → `delivering`). |
| `mark_delivery_delivered(request_id)` | Marque une livraison comme effectuée (statut commande → `delivered`). |
| `release_delivery_request(request_id)` | Le livreur rend la livraison au tableau (statut commande → `preparing`). |
| `get_delivery_contact(request_id)` | Renvoie les coordonnées du client **uniquement** au livreur assigné à cette livraison. |
| `payment_gap(order)` | Écart entre le montant reçu déclaré par le vendeur et le total de la commande. |
| `inclusion_stats()` | Statistiques agrégées et anonymisées (nombre de boutiques, part déclarée tenue par des femmes, nombre de villes) — mesure d'impact, jamais utilisée comme filtre ou score. |

## Stockage (Storage)

6 buckets, tous en écriture réservée aux utilisateurs authentifiés :

| Bucket | Public | Contenu |
|---|---|---|
| `shop-images` | ✅ | Logos de boutique. |
| `product-images` | ✅ | Photos produit. |
| `category-images` | ✅ | Photos de catégorie. |
| `banner-images` | ✅ | Bannières et vitrines de la page d'accueil. |
| `avatars` | ✅ | Photo de profil (écriture restreinte à son propre dossier `auth.uid()`). |
| `payment-proofs` | ❌ privé | Captures d'écran de paiement (lecture/écriture réservées à leur auteur). |

## Temps réel

`delivery_requests` est ajoutée à la publication `supabase_realtime` : le tableau des livraisons disponibles côté livreur se met à jour en direct sans polling, dès qu'une nouvelle demande apparaît ou qu'une autre est prise par un autre livreur.

## Écart connu entre le code SQL versionné et la base réelle

Honnêteté technique : une partie du schéma ci-dessus a été appliquée directement depuis l'éditeur SQL de Supabase au fil du projet, sans toujours être reportée dans les fichiers `supabase/*.sql` du dépôt. Confirmé en croisant le code de l'app (modèles, services) avec les fichiers versionnés, **n'existent que dans la base réelle, pas dans le dépôt** :

- Les tables `home_banners`, `home_collections`, `notifications`, `app_settings` en entier.
- Sur `shops` : `merchant_code`, `merchant_provider`.
- Sur `categories` : `image_url`, `focal_x`, `focal_y`, `zoom`.
- Sur `products` : `brand`, `compare_at_price`, `option_name`, `option_values`, `option_type`, `option_colors`, `option_sold_out`.
- Sur `product_images` : `focal_x`, `focal_y`, `zoom`.
- Sur `orders` : `payment_reference`, `delivery_lat`, `delivery_lng`, `delivery_mode`.
- Sur `profiles` : `gender`.

Les fichiers `supabase/*.sql` du dépôt restent la référence pour tout ce qu'ils couvrent (schéma cœur, RLS, livraison, anti-conflit d'intérêt, suivi de paiement, buckets de stockage) — mais ne suffisent pas, seuls, à recréer la base actuelle à l'identique.

## Fichiers du dépôt, dans l'ordre d'exécution

1. `marketplace_schema.sql` — schéma de base : tables cœur, RLS, fonctions, 4 buckets.
2. `livreur_patch.sql` — espace livreur, table `delivery_requests`, calcul de distance.
3. `livreur_patch_2_grants.sql` — droits d'exécution sur les fonctions livreur.
4. `livreur_patch_3_approval.sql` — validation admin des candidatures livreur.
5. `anti_self_dealing_patch.sql` — règles anti-conflit d'intérêt vendeur/livreur.
6. `reviews_patch_purchase_required.sql` — un avis nécessite un achat réel.
7. `vendor_payment_tracking_patch.sql` — suivi du statut de paiement, mesure d'impact `women_led`.
8. `category_banner_storage_patch.sql` — buckets `category-images` et `banner-images` (manquants du schéma initial).
