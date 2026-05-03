# 🔐 Sécurisation des Sessions BGP
## en Cœur de Réseau Opérateur

**ENSA Marrakech — Université Cadi Ayyad**
**Encadré par : Pr. OUATIL Anas**
**Réalisé par : AIT SI AHMED Abdellatif**

---

## 📋 Description
Implémentation d'une architecture de
sécurisation BGP avec 3 AS autonomes,
validation RPKI et supervision réseau.

## 🛠️ Outils utilisés
- Docker 29.4
- FRRouting 8.4
- Routinator 0.15.1
- Wireshark 4.2
- Ubuntu 24.04 LTS

## ✅ Résultats
- Sessions BGP Established entre AS100/200/300
- 175,000+ ROAs chargés (RPKI)
- Détection hijacking INVALID prouvée
- Capture Wireshark BGP port 179
