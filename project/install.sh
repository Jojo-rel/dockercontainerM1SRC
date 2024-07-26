#!/bin/bash

# Charger les fichiers de configuration et les fonctions
source config.sh
source functions.sh

# Afficher un message d'introduction sur ce que fait le script
echo "Ce script installe et configure Docker, GlusterFS et Keepalived sur les 3 noeuds"

# Installer Docker localement
install_docker_local

# Initialiser le cluster Docker Swarm sur le noeud local
docker swarm init --data-path-port=9789 --advertise-addr $DOCKER_IP

# Installation de Docker sur le noeud 2
install_docker $REMOTE_HOST1 $REMOTE_HOST1_USER $REMOTE_HOST1_PASS
join_swarm $REMOTE_HOST1 $REMOTE_HOST1_USER $REMOTE_HOST1_PASS

# Installation de Docker sur le noeud 3
install_docker $REMOTE_HOST2 $REMOTE_HOST2_USER $REMOTE_HOST2_PASS
join_swarm $REMOTE_HOST2 $REMOTE_HOST2_USER $REMOTE_HOST2_PASS

# Installation de GlusterFS localement
install_glusterfs_local

# Partitionner et formater le disque localement
partition_disk_local

# Installer GlusterFS sur le noeud 2 et partitionner le disque
install_glusterfs $REMOTE_HOST1 $REMOTE_HOST1_USER
partition_disk $REMOTE_HOST1 $REMOTE_HOST1_USER

# Installer GlusterFS sur le noeud 3 et partitionner le disque
install_glusterfs $REMOTE_HOST2 $REMOTE_HOST2_USER
partition_disk $REMOTE_HOST2 $REMOTE_HOST2_USER

# Configurer GlusterFS localement
configure_glusterfs_local

# Configurer GlusterFS sur le noeud 2
configure_glusterfs2 $REMOTE_HOST1 $REMOTE_HOST1_USER

# Configurer GlusterFS sur le noeud 3
configure_glusterfs3 $REMOTE_HOST2 $REMOTE_HOST2_USER

# Ajouter des pairs GlusterFS
execute_local_commands "
    gluster peer probe $REMOTE_HOST1
    gluster peer probe $REMOTE_HOST2
"

# Création du volume GlusterFS
create_gluster_volume

# Monter le volume GlusterFS localement
mount_gluster_volume_local

# Monter le volume GlusterFS sur le noeud 2
mount_gluster_volume $REMOTE_HOST1 $REMOTE_HOST1_USER

# Monter le volume GlusterFS sur le noeud 3
mount_gluster_volume $REMOTE_HOST2 $REMOTE_HOST2_USER

# Installer Keepalived localement
install_keepalived_local

# Configurer Keepalived localement
configure_keepalived_local

# Installer Keepalived sur le noeud 2 et configurer
install_keepalived $REMOTE_HOST1 $REMOTE_HOST1_USER
configure_keepalived1 $REMOTE_HOST1 $REMOTE_HOST1_USER

# Installer Keepalived sur le noeud 3 et configurer
install_keepalived $REMOTE_HOST2 $REMOTE_HOST2_USER
configure_keepalived2 $REMOTE_HOST2 $REMOTE_HOST2_USER
