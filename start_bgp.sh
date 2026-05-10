#!/bin/bash
echo "============================================"
echo "  Démarrage Infrastructure BGP Sécurisée"
echo "  ENSA Marrakech — Projet Sécurité Réseaux"
echo "============================================"

# Créer les conteneurs s'ils n'existent pas
if [ ! "$(docker ps -a -q -f name=AS100)" ]; then
    echo "▶ Création des conteneurs Docker..."
    docker network create --subnet=192.168.100.0/24 bgp-net 2>/dev/null

    docker run -d --name AS100 \
      --network bgp-net --ip 192.168.100.10 \
      --privileged frrouting/frr:latest

    docker run -d --name AS200 \
      --network bgp-net --ip 192.168.100.20 \
      --privileged frrouting/frr:latest

    docker run -d --name AS300 \
      --network bgp-net --ip 192.168.100.30 \
      --privileged frrouting/frr:latest

    docker exec AS100 sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons
    docker exec AS200 sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons
    docker exec AS300 sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons

    docker restart AS100 AS200 AS300
    sleep 5
    echo "✅ Conteneurs créés !"
fi

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
