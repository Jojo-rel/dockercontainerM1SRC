#!/bin/bash

# Chemin absolu du script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
DIRS=(
    "wordpress/wp_content"
    "wordpress/mysql"
    "grafana_volumes"
    "compose/wordpress"
    "compose/grafana"
    "compose/prometheus"
)

# Suppression des stacks Docker
echo "Suppression des stacks Docker..."
docker stack rm wordpress
docker stack rm grafana
docker stack rm prometheus

# Attendre que les stacks soient complètement supprimées
sleep 10

# Suppression des fichiers dans les répertoires
echo "Suppression des fichiers dans les répertoires..."
for dir in "${DIRS[@]}"; do
    if [ -d "/mnt/$dir" ]; then
        echo "Suppression du répertoire /mnt/$dir"
        rm -rf "/mnt/$dir"
    fi
done

# Vérification des répertoires restants
echo "Vérification des répertoires restants..."
for dir in "${DIRS[@]}"; do
    if [ -d "/mnt/$dir" ]; then
        echo "Le répertoire /mnt/$dir existe toujours."
    else
        echo "Le répertoire /mnt/$dir a été supprimé avec succès."
    fi
done

echo "Nettoyage terminé avec succès."
