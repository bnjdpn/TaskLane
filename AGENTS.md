# TaskLane

Lire [CLAUDE.md](CLAUDE.md) pour l'architecture, les commandes et les contraintes
natives existantes. Préserver les changements locaux et les paramètres utilisateur.
Ne pas déclencher de demandes système d'enregistrement d'écran/accessibilité
pendant les builds ou tests ; ces permissions restent une action de l'utilisateur.

## Sources web

`Scripts/site-content.mjs` et `Scripts/build-site.mjs` génèrent `docs/index.html`,
`docs/fr/index.html` et `docs/sitemap.xml`. Modifier ces sources avant de régénérer.
Les styles/scripts/assets éditables restent sous `docs/assets/`. Lire
[docs/design.md](docs/design.md) pour la provenance des captures natives.
Contrôler `node Scripts/build-site.mjs --check && node Scripts/check-site.mjs`.

## Cohérence du site avec les releases

Toute modification susceptible de rendre la présentation publique inexacte ou obsolète doit déclencher une vérification du site associé. Si nécessaire, sa mise à jour fait partie du travail à livrer, sans que Benjamin ait à le redemander. Sinon, indiquer brièvement pourquoi le changement n’a aucun impact sur le site.

Appliquer le skill portable [site-release-sync](.agents/skills/site-release-sync/SKILL.md), y compris pour conclure sans impact. Sa carte locale identifie les sources du site, captures, langues, validations et publication. Fonctionnalités, UI/navigation, captures, noms, compatibilité, plateformes, monétisation et traitement des données sont concernés. Préparer les nouveautés avec la release ; les promesses de disponibilité attendent la lecture des assets publics sur chaque plateforme.
