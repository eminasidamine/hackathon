# Boutigui — Marketplace & inclusion financière pour les petits commerçants mauritaniens

## Résumé

Boutigui est une marketplace mobile multi-vendeurs qui permet aux petits commerçants mauritaniens de vendre en ligne, de se faire livrer via un réseau de livreurs géolocalisés, et — c'est ce qui la différencie d'une marketplace classique — de transformer automatiquement leur activité réelle en un profil financier vérifiable et exportable, consultable par une banque ou un partenaire financier.

## Le problème

Les petits commerçants (boutiques de quartier, artisans, vendeurs de produits locaux) n'ont aujourd'hui aucune infrastructure numérique pour :
- **Vendre au-delà de leur cercle de proximité** — ils dépendent de WhatsApp, du bouche-à-oreille et du cash.
- **Faire livrer leurs produits de façon fiable** — les circuits de livraison informels ne sont ni tracés ni garantis.
- **Prouver leur activité économique** — aucun historique de ventes, aucune preuve de paiement, aucun registre exploitable.

La conséquence la plus grave : quand ces commerçants ont besoin de financement pour grandir, ils n'ont **rien à montrer** à une banque ou un bailleur. Leur activité peut être parfaitement viable — elle reste invisible pour tout système de crédit. Ce n'est pas un problème d'accès au crédit, mais d'invisibilité économique.

### Ampleur du problème

- **Mauritanie** : ~4,9 millions d'habitants ; le secteur informel domine largement l'emploi hors agriculture au Sahel. Estimation raisonnable : **150 000 à 300 000 petits commerçants et indépendants** concernés à l'échelle nationale.
- **Espace OCI** : 57 pays, ~1,9 milliard d'habitants, avec une forte proportion de zones à faible bancarisation et à économie informelle dominante (Afrique subsaharienne, Sahel, certaines régions d'Asie). Le même problème structurel touche des **dizaines de millions de commerçants**.

## La solution en une phrase

Une marketplace mobile qui permet aux petits commerçants de vendre en ligne, de se faire livrer via un réseau de livreurs géolocalisés, et de transformer automatiquement leur activité réelle en un profil financier vérifiable et téléchargeable.

## Comment ça marche

**Le client** parcourt les boutiques et produits, passe commande, paie (référence bancaire / mobile money), et suit sa livraison sur une carte interactive en temps réel.

**Le commerçant (vendeur)** crée sa boutique en quelques minutes, gère ses produits et ses commandes. Sans effort supplémentaire, l'app génère :
- un tableau de bord de ventes ("Mon activité") : chiffre d'affaires, commandes, clients, croissance, répartition des paiements, meilleurs produits ;
- un **score de préparation financière** basé sur la régularité de l'activité, le volume de commandes, les paiements numériques confirmés et la complétude du profil boutique ;
- un **profil d'entreprise exportable en PDF**, prêt à être présenté à une banque ou un partenaire financier.

**Le livreur** voit les livraisons disponibles sur un tableau, accepte une course, navigue jusqu'à l'adresse exacte via une carte interactive, marque la livraison comme effectuée (et peut l'annuler proprement si besoin).

## Ce qui différencie Boutigui

| | WhatsApp / bouche-à-oreille | Cash | Marketplace classique | **Boutigui** |
|---|---|---|---|---|
| Catalogue structuré | ❌ | ❌ | ✅ | ✅ |
| Historique de ventes exploitable | ❌ | ❌ | ⚠️ partiel | ✅ |
| Preuve de paiement | ❌ | ❌ | ⚠️ | ✅ (traçabilité + vérification vendeur) |
| Livraison structurée et suivie | ❌ | ❌ | ⚠️ | ✅ (carte interactive, responsabilisation du livreur) |
| Profil financier exportable | ❌ | ❌ | ❌ | ✅ |

Le vrai verrou que Boutigui adresse n'est pas l'accès à des clients, mais **l'invisibilité économique face au système financier formel** — un problème qu'aucune marketplace généraliste ne traite.

## Fonctionnalités clés

- Marketplace multi-vendeurs (catalogue, panier multi-boutiques, favoris, recherche)
- Paiement par référence bancaire / mobile money, avec vérification par le vendeur
- Livraison géolocalisée avec carte interactive (OpenStreetMap), tableau des courses disponibles, suivi et annulation
- Règles anti-conflit d'intérêt : un vendeur ne peut pas commander dans sa propre boutique ; un livreur ne peut pas accepter la livraison de sa propre commande
- Tableau de bord vendeur ("Mon activité") : ventes, paiements, produits, score de préparation financière, analyses automatiques
- Profil d'entreprise généré automatiquement et exportable en PDF
- Application entièrement multilingue (français / arabe / anglais)
- Back-office administrateur (produits, boutiques, commandes, bannières, catégories)

## Modèle économique

1. **Court terme (traction)** : commission sur chaque transaction + frais sur la livraison.
2. **Moyen terme (le vrai levier)** : commission d'apport (type *ujrah*, sans intérêt — conforme aux principes de finance islamique) versée par une institution financière ou de microfinance lorsqu'un commerçant obtient un financement grâce à son profil vérifié sur la plateforme. Complémentaire : accès à des données agrégées et anonymisées pour des institutions de développement travaillant sur l'inclusion financière.

*Principe directeur : on ne facture pas le commerçant pauvre pour ce qu'il gagne à être visible — on facture l'institution qui gagne à le connaître.*

## Secteur

**Fintech** (principal) — la marketplace est le véhicule, mais la couche différenciante (suivi des paiements, score de préparation financière, profil exportable) répond directement au problème d'inclusion financière. Secteurs secondaires : E-commerce & distribution, Logistique.

## Stack technique

- **Application** : Flutter (mobile + web), déployée sur Netlify / Cloudflare Pages
- **Backend** : Supabase (PostgreSQL, authentification, Row Level Security, fonctions `security definer`)
- **Cartographie** : OpenStreetMap via `flutter_map` (aucune clé API requise)
- **Génération de documents** : PDF généré côté client (package `pdf`/`printing`)
- **Internationalisation** : système de traduction interne fr/ar/en

## Impact visé

Construire, à partir de données réelles et non déclaratives, un début de dossier de crédit pour des commerçants aujourd'hui exclus du système financier formel — non pas en leur demandant un effort supplémentaire, mais comme sous-produit naturel de l'usage de l'application pour ce qu'ils veulent déjà faire : vendre plus.
