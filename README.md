# 🛡️ Sécurisation des Sessions BGP — ENSA Marrakech

> Infrastructure Docker multi-AS simulant un réseau BGP réel avec authentification MD5, filtrage bogons RFC1918 et validation RPKI/ROA via Routinator (175 000+ ROAs validés).

**Module** : Sécurité des Réseaux et Protocoles  
**Filière** : GCDSTE — Génie Cyber-Défense et Systèmes de Télécommunications Embarqués  
**Établissement** : ENSA Marrakech | Année universitaire 2025/2026  
**Réalisé par** : AIT SI AHMED Abdellatif

---

## 🏗️ Architecture Multi-AS

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet simulé                           │
│                                                             │
│   AS100 (Tier-1)          AS200 (Opérateur)                │
│   ┌──────────────┐        ┌──────────────┐                  │
│   │  FRRouting   │◄──────►│  FRRouting   │                  │
│   │  10.0.0.1    │  BGP   │  10.0.0.2    │                  │
│   │  MD5 Auth    │  eBGP  │  MD5 Auth    │                  │
│   └──────┬───────┘        └──────┬───────┘                  │
│          │                       │                          │
│          └──────────┬────────────┘                          │
│                     │ BGP                                   │
│              ┌──────▼───────┐                               │
│              │  AS300       │                               │
│              │ (Customer)   │                               │
│              │  FRRouting   │                               │
│              │  10.0.0.3    │                               │
│              └──────────────┘                               │
│                                                             │
│   ┌──────────────────────────┐                             │
│   │  Routinator (RPKI)       │                             │
│   │  175 000+ ROAs validés   │                             │
│   │  Port 3323 (RTR)         │                             │
│   └──────────────────────────┘                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Mécanismes de sécurité implémentés

| Mécanisme | Détail | Statut |
|---|---|---|
| **Authentification MD5** | Sessions BGP signées MD5 entre tous les AS | ✅ |
| **Filtrage bogons** | Rejet préfixes RFC1918 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) | ✅ |
| **RPKI/ROA** | Validation via Routinator — VALID / INVALID / NOT FOUND | ✅ |
| **Prefix-list** | Filtrage entrant/sortant sur chaque peering | ✅ |
| **Route-map** | Politique de routage par AS | ✅ |
| **Capture Wireshark** | Analyse trafic BGP port 179 — MD5 option visible | ✅ |

---

## 📦 Infrastructure Docker

| Conteneur | Image | Rôle | AS |
|---|---|---|---|
| `r1` | `frrouting/frr:v8.4.0` | Tier-1 Router | AS100 |
| `r2` | `frrouting/frr:v8.4.0` | Opérateur | AS200 |
| `r3` | `frrouting/frr:v8.4.0` | Customer | AS300 |
| `routinator` | `nlnetlabs/routinator` | Validateur RPKI | — |

---

## 🚀 Lancement rapide

```bash
# Cloner le repo
git clone https://github.com/AbdellatifAitSiAhmed/bgp-securisation-ensa.git
cd bgp-securisation-ensa

# Lancer l'infrastructure
bash start_bgp.sh

# Vérifier les sessions BGP
docker exec r1 vtysh -c "show bgp summary"
docker exec r2 vtysh -c "show bgp summary"
docker exec r3 vtysh -c "show bgp summary"
```

---

## 🧪 Tests de validation RPKI

```bash
# Test préfixe VALID
docker exec r1 vtysh -c "show bgp ipv4 unicast 1.1.1.0/24"
# → rpki state: valid ✅

# Test préfixe INVALID
docker exec r1 vtysh -c "show bgp ipv4 unicast 8.8.8.0/24"
# → rpki state: invalid ✅

# Test préfixe NOT FOUND
docker exec r1 vtysh -c "show bgp ipv4 unicast 100.64.0.0/10"
# → rpki state: notfound ✅

# Vérifier Routinator
docker exec routinator routinator vrps --format csv | wc -l
# → 175 000+ ROAs ✅
```

---

## 📁 Structure du projet

```
bgp-securisation-ensa/
├── configs/
│   ├── r1/
│   │   └── frr.conf        # Config AS100 — MD5 + filtrage bogons
│   ├── r2/
│   │   └── frr.conf        # Config AS200 — MD5 + prefix-list
│   ├── r3/
│   │   └── frr.conf        # Config AS300 — MD5 + route-map
│   └── routinator/
│       └── routinator.conf # Config RPKI validator
├── screenshots/
│   ├── bgp-sessions.png    # Sessions eBGP établies
│   ├── rpki-valid.png      # Test VALID
│   ├── rpki-invalid.png    # Test INVALID
│   ├── wireshark-179.png   # Capture port 179 MD5
│   └── routinator-roas.png # 175 000+ ROAs
├── start_bgp.sh            # Script de démarrage
├── docker-compose.yml
└── README.md
```

---

## ✅ Résultats de validation

| Test | Résultat |
|------|----------|
| Sessions eBGP AS100↔AS200 | ✅ Établies |
| Sessions eBGP AS200↔AS300 | ✅ Établies |
| Authentification MD5 | ✅ Validée (Wireshark port 179) |
| Filtrage bogons RFC1918 | ✅ Préfixes rejetés |
| RPKI VALID (1.1.1.0/24) | ✅ Accepté |
| RPKI INVALID | ✅ Rejeté |
| RPKI NOT FOUND | ✅ Détecté |
| Routinator ROAs | ✅ 175 000+ validés |

---

## 🛠️ Stack technique

![FRRouting](https://img.shields.io/badge/FRRouting-v8.4.0-003366?logo=linux&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![RPKI](https://img.shields.io/badge/RPKI-Routinator-FF6600?logoColor=white)
![BGP](https://img.shields.io/badge/BGP-eBGP_Multi--AS-009900?logoColor=white)
![Wireshark](https://img.shields.io/badge/Wireshark-Port_179-1679A7?logo=wireshark&logoColor=white)
