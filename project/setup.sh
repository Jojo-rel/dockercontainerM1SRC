#!/bin/bash

# Fonction pour demander l'état des packages
ask_packages_state() {
    while true; do
        read -p "Les packages sont déjà installés (y ou n) ? " packages_state

        packages_state=$(echo "$packages_state" | tr '[:upper:]' '[:lower:]')

        case "$packages_state" in
            y|n)
                break
                ;;
            *)
                echo "Réponse invalide. Veuillez entrer 'y' pour oui ou 'n' pour non."
                ;;
        esac
    done
}

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

# Avertissement utilisateur
echo "Packages nécessaires pour utiliser ce script : tree"
ask_packages_state
if [ "$packages_state" == "y" ]; then
    echo "OK, pas d'installation de packages"
    # Ajoutez ici les commandes pour le cas où les packages sont déjà installés
elif [ "$packages_state" == "n" ]; then
    echo "OK, installation en cours"
    apt update -y && apt upgrade -y
    apt install -y tree
fi

read -p "Quel utilisateur est utilisé pour lancer Docker (ex: user:group) ? " docker_user

# Déplacement dans /mnt
cd /mnt || { echo "Erreur : impossible de se déplacer dans /mnt"; exit 1; }

# Création des dossiers
for dir in "${DIRS[@]}"; do
    mkdir -p "$dir"
done

# Copie des fichiers compose dans les répertoires :
cp "$SCRIPT_DIR"/wordpress/compose.yml "${DIRS[3]}/"
cp "$SCRIPT_DIR"/grafana/compose.yml "${DIRS[4]}/"
cp "$SCRIPT_DIR"/prometheus/compose.yml "${DIRS[5]}/"
cp "$SCRIPT_DIR"/prometheus/alert_manager.yml "${DIRS[5]}/"
cp "$SCRIPT_DIR"/prometheus/rules.yml "${DIRS[5]}/"
cp "$SCRIPT_DIR"/prometheus/prometheus.yml "${DIRS[5]}/"

# Changement des droits des répertoires
for dir in "${DIRS[@]}"; do
    chown -R "$docker_user" "$dir"
done

# Lancement des stacks
docker stack deploy -c "${DIRS[3]}/compose.yml" wordpress
docker stack deploy -c "${DIRS[4]}/compose.yml" grafana
docker stack deploy -c "${DIRS[5]}/compose.yml" prometheus

echo "Arborescence de /mnt: "
tree /mnt

sleep 5
