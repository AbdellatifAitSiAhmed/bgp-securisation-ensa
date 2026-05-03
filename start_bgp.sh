#!/bin/bash
echo "============================================"
echo "  Démarrage Infrastructure BGP Sécurisée"
echo "  ENSA Marrakech — Projet Sécurité Réseaux"
echo "============================================"

# Étape 1 — Démarrer les conteneurs
echo ""
echo "▶ Démarrage des conteneurs Docker..."
docker start AS100 AS200 AS300
sleep 3

# Étape 2 — Lancer bgpd dans chaque AS
echo "▶ Lancement BGP daemon AS100..."
docker exec AS100 /usr/lib/frr/bgpd -d -F traditional -A 127.0.0.1 2>/dev/null

echo "▶ Lancement BGP daemon AS200..."
docker exec AS200 /usr/lib/frr/bgpd -d -F traditional -A 127.0.0.1 2>/dev/null

echo "▶ Lancement BGP daemon AS300..."
docker exec AS300 /usr/lib/frr/bgpd -d -F traditional -A 127.0.0.1 2>/dev/null

# Étape 3 — Attendre convergence BGP
echo ""
echo "⏳ Attente convergence BGP (30 secondes)..."
sleep 30

# Étape 4 — Vérification
echo ""
echo "▶ Vérification sessions BGP..."
docker exec AS200 vtysh -c "show bgp summary"

echo ""
echo "▶ Vérification Routinator RPKI..."
systemctl status routinator | grep "Active:"

echo ""
echo "============================================"
echo "✅ Infrastructure BGP prête !"
echo "✅ Routinator : http://localhost:8323"
echo "============================================"
