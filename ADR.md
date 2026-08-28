# Journal ADR — bilan-azure-quiz-infra

Ce document recense les décisions techniques structurantes prises pendant ce projet, au format ADR (*Architecture Decision Record*) : contexte, décision, alternatives envisagées, conséquences.

## ADR 1 — Périmètre de gestion IaC face à l'infrastructure mutualisée

**Statut** : Accepté (2026-08-27)

### Contexte
Le cahier des charges impose de référencer l'App Service Plan mutualisé (`plan-npr-prf2026`, groupe `rg-shared-prf2026`) en data source plutôt que de le créer. Lors du développement du pipeline CI/CD, l'identité GitHub Actions (`id-github-actions-fbarry`) avait besoin d'un accès en lecture à ce plan pour que `terraform plan`/`apply` fonctionnent. Une tentative de créer cette attribution de rôle directement en Terraform (`azurerm_role_assignment` scopée sur la ressource) a échoué avec une erreur 403 : ni le compte étudiant ni son identité CI ne disposent du droit `Microsoft.Authorization/roleAssignments/write` sur ce groupe de ressources, qui appartient au formateur — confirmé aussi dans le portail Azure (bouton "Add role assignment" grisé).

### Décision
Ne pas essayer de gérer ce droit d'accès en Terraform. Le bloc `azurerm_role_assignment` correspondant a été supprimé du code, et l'accès a été obtenu via une intervention manuelle du formateur, qui a accordé le rôle "Reader" à l'identité CI directement dans le portail Azure, au niveau du groupe de ressources partagé.

### Alternatives envisagées
- Essayer d'élever les droits du compte étudiant sur `rg-shared-prf2026` — rejeté : ce groupe appartient à un tiers (le formateur), il n'y a aucune raison légitime que l'étudiant y ait des droits d'écriture sur les accès.
- Dupliquer l'App Service Plan dans `fbarryRG` pour le gérer intégralement soi-même — rejeté : contredit explicitement le cahier des charges, qui impose de référencer le plan mutualisé en lecture seule.

### Conséquences
Le code Terraform du dépôt reflète honnêtement le périmètre réel de ce que l'étudiant contrôle — tout `fbarryRG` en propre, rien sur `rg-shared-prf2026` au-delà d'un accès en lecture accordé de l'extérieur. Ce n'est pas un import incomplet ni un oubli : c'est une frontière de responsabilité correctement représentée. Toute évolution future de cet accès devra être redemandée manuellement au formateur (pas de "self-service" possible ici, par design).

## ADR 2 — CORS + clé API partagée en repli pour l'exposition du backend

**Statut** : Accepté (2026-08-27)

### Contexte
Le cahier des charges impose que seul le frontend soit exposé sur Internet, le backend ne devant être joignable que depuis le frontend. Une Azure Static Web App ne fait pas transiter les appels API par un serveur intermédiaire (sauf via un "linked backend" basé sur Azure Functions, fonctionnalité payante allant au-delà du périmètre "services managés" simples visé par ce projet) : les appels API partent directement du navigateur de l'utilisateur final vers le backend, sans passer par aucun serveur du site. Le endpoint HTTPS du backend est donc, au niveau réseau, atteignable par n'importe qui sur Internet.

### Décision
Assumer cette exposition réseau et la compenser par deux contrôles applicatifs plutôt que réseau : un CORS restreint à l'origine exacte du frontend (`APP_CORS_ALLOWED_ORIGINS`), et une clé API partagée obligatoire (`X-Api-Key`) que seul le frontend légitime connaît (injectée uniquement à la construction du frontend en CI, jamais committée).

### Alternatives envisagées
- Linked backend Azure Functions (couplage natif Static Web App ↔ API, isolation réseau réelle) — rejeté : fonctionnalité payante (tier Standard), hors du choix "services managés" simples validé pour ce projet, et complexité supplémentaire disproportionnée pour ce TP.
- Ne rien faire et laisser l'API entièrement publique sans contrôle applicatif — rejeté : contredit frontalement la contrainte du cahier des charges.
- Authentification utilisateur complète (compte, JWT par utilisateur) — rejeté : hors scope (l'application est explicitement accessible "sans compte"), aurait ajouté une complexité non demandée.

### Conséquences
La sécurité du backend repose sur un secret partagé plutôt que sur une isolation réseau — un choix pragmatique documenté et assumé, pas une faille cachée. Point important à ne pas mal représenter à l'oral : CORS seul ne protège rien côté serveur (c'est une règle respectée par les navigateurs, pas un contrôle d'accès) — c'est la clé API qui constitue la vraie barrière.

## ADR 3 — Authentification OIDC et résolution des ressources Azure par tag dans le pipeline CI/CD

**Statut** : Accepté (2026-08-27)

### Contexte
Le pipeline CI/CD du frontend doit connaître, au moment du build, l'URL réelle du backend et la clé API partagée — deux valeurs qui ne doivent jamais être committées dans le code (cahier des charges : pas de secret en dur) ni codées en dur par leur nom de ressource Azure (critère de notation : "CI/CD (déploiement + récupération par tags)"). Le fichier `environment.ts` fourni par le formateur contenait déjà des jetons placeholder avec un commentaire explicite indiquant cette attente.

### Décision
Le pipeline GitHub Actions du frontend s'authentifie à Azure via OIDC (fédération d'identité, `azurerm_federated_identity_credential`, aucun secret à long terme stocké dans GitHub), puis interroge l'API Azure pour retrouver la Web App backend et le Key Vault **par leur tag `composant`** (`composant=backend`, `composant=key-vault`) plutôt que par un nom écrit en dur. Il lit ensuite la clé API dans le Key Vault trouvé, et substitue les deux valeurs dans `environment.ts` via `sed`, uniquement sur le runner CI éphémère, juste avant le build.

### Alternatives envisagées
- Coder en dur les noms de ressources dans le pipeline — rejeté : fonctionne, mais casse dès qu'une ressource est renommée ou recréée, et ne répond pas au critère explicite de notation sur la récupération par tags.
- Passer l'URL du backend et la clé API en secrets/variables GitHub configurés manuellement — rejeté : demande une resynchronisation manuelle à chaque changement d'infra, et ne démontre pas la découverte dynamique de ressources attendue par le cahier des charges.
- Utiliser les outputs Terraform du dépôt infra directement dans le pipeline frontend (couplage entre dépôts) — rejeté : complexifie inutilement le lien entre les 3 dépôts, qui doivent rester indépendants ; la résolution par tag au runtime du pipeline est plus simple et répond directement au critère demandé.

### Conséquences
Le frontend n'a jamais besoin de connaître à l'avance le nom exact des ressources Azure : elles peuvent être renommées ou recréées sans modifier le pipeline. Le secret (clé API) ne transite que sur le runner CI éphémère, jamais committé, et masqué explicitement dans les logs (`::add-mask::`). Ce mécanisme dépend cependant de la stabilité de la convention de tags (`composant=...`) — un changement de convention casserait la résolution, ce qui en fait un contrat implicite entre le dépôt infra et le dépôt frontend.