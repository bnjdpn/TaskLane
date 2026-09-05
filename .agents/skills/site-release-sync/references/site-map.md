# TaskLane : carte du site et de sa release

| Élément | Source / procédure |
| --- | --- |
| Dépôt / URL | `bnjdpn/TaskLane` · [site public](https://bnjdpn.github.io/TaskLane/) |
| Sources | [Scripts/site-content.mjs](../../../../Scripts/site-content.mjs), [Scripts/build-site.mjs](../../../../Scripts/build-site.mjs) et [docs/assets](../../../../docs/assets/) ; les HTML dans `docs/` sont générés. [docs/_config.yml](../../../../docs/_config.yml) conserve la configuration historique Pages |
| Surfaces | `/`, `/fr/`, sitemap ; sections produit, installation, téléchargement et support dans les deux langues |
| Langues | Français et anglais : contenu dans `Scripts/site-content.mjs`, routes générées `/fr/` et `/` ; canoniques et alternates dans le générateur |
| Captures | `Scripts/capture-site.swift` et `Scripts/capture-site.sh` capturent les vues natives avec données de démonstration ; `docs/assets/images/taskbar-light.png` et `taskbar-dark.png`, icône et partage. Ne pas afficher de noms de fenêtres personnels |
| Disponibilité | Assets DMG/ZIP de la [release GitHub publique](https://github.com/bnjdpn/TaskLane/releases). Ni `Package.swift`, ni un tag ne prouvent la compatibilité du binaire disponible ; vérifier notamment la version minimale macOS |
| Validation | `node Scripts/build-site.mjs`, puis `node Scripts/build-site.mjs --check` et `node Scripts/check-site.mjs` ; garde Ruby et simulations du skill. Servir `docs/` et vérifier routes, FR/EN, images, clavier, formats mobile/tablette/desktop et console |
| Release | [.github/workflows/release.yml](../../../../.github/workflows/release.yml) construit puis attache DMG/ZIP ; revue web à préparer dans les artefacts ignorés ou hors du checkout. Aucun Fastlane dans ce dépôt |
| Catalogue | `bnjdpn/bnjdpn.github.io` seulement après confirmation du contenu et de la disponibilité à présenter ; ne pas transformer l'existence d'un dépôt en promesse de téléchargement |
| Publication | GitHub Pages historique : branche `main`, dossier `/docs` ; un push de ces sources peut publier. Aucun workflow de déploiement supplémentaire n'est ajouté. Autorisation explicite avant le push, puis lecture du site réellement servi |

Les contrôles du skill sont intégrés au build et à la release existants. Ils ne
valident ni les autorisations macOS réelles, ni la signature/notarisation, ni les
promesses publiques : ces preuves restent distinctes. Lire [le contrat](review.md).
