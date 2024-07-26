#!/bin/bash

execute_remote_commands() {
    # Exécute des commandes sur un serveur distant via SSH
    ssh -i $3 -o StrictHostKeyChecking=no $2@$1 "$4"
}

execute_local_commands() {
    # Exécute des commandes localement
    source config.sh;
    eval "$1"
}

install_docker() {
    # Installe Docker sur le serveur distant
    echo "Installation de Docker sur le serveur distant $1 avec l'utilisateur $2..."
    execute_remote_commands $1 $2 $3 $4"
        curl -fsSL https://get.docker.com -o install-docker.sh
        chmod +x install-docker.sh
        ./install-docker.sh
    "
}

install_docker_local() {
    # Installe Docker localement
    echo "Installation de Docker localement..."
    execute_local_commands "
        curl -fsSL https://get.docker.com -o install-docker.sh
        chmod +x install-docker.sh
        ./install-docker.sh
    "
}

join_swarm() {
    # Rejoint le cluster Docker Swarm en tant que manager
    join_command=$(docker swarm join-token manager -q)
    echo "Le serveur $1 rejoint le cluster Docker Swarm avec le token..."
    execute_remote_commands $1 $2 $3"docker swarm join --token $join_command $DOCKER_IP:2377"
}

partition_disk() {
    # Partitionne un disque sur le serveur distant
    echo "Partitionnement du disque $4 sur le serveur distant $1..."
    execute_remote_commands $1 $2 $3 $4"
        parted $DISK --script mklabel gpt
        parted $DISK --script mkpart primary 0% 100%
        mkfs.xfs -i size=512 ${DISK}1
    "
}

partition_disk_local() {
    # Partitionne un disque localement
    echo "Partitionnement du disque localement..."
    execute_local_commands "
        parted $DISK --script mklabel gpt
        parted $DISK --script mkpart primary 0% 100%
        mkfs.xfs -i size=512 ${DISK}1
    "
}

install_glusterfs() {
    # Installe GlusterFS sur le serveur distant
    echo "Installation de GlusterFS sur le serveur distant $1..."
    execute_remote_commands $1 $2 $3 $4"
        apt update
        apt install -y software-properties-common xfsprogs glusterfs-server
        systemctl enable glusterd
        systemctl start glusterd
    "
}

install_glusterfs_local() {
    # Installe GlusterFS localement
    echo "Installation de GlusterFS localement..."
    execute_local_commands "
        apt update
        apt install -y software-properties-common xfsprogs glusterfs-server
        systemctl enable glusterd
        systemctl start glusterd
    "
}

configure_glusterfs2() {
    # Configure GlusterFS sur le serveur distant pour le point de montage 2
    echo "Configuration de GlusterFS pour le point de montage 2 sur le serveur $1..."
    execute_remote_commands $1 $2 $3 $4"
        mkdir -p $MOUNT_POINT/2
        echo '${DISK}1 $MOUNT_POINT/2 xfs defaults 0 0' >> /etc/fstab
        mount -a
        mkdir -p $MOUNT_POINT/2/$BRICK_DIR
    "
}

configure_glusterfs3() {
    # Configure GlusterFS sur le serveur distant pour le point de montage 3
    echo "Configuration de GlusterFS pour le point de montage 3 sur le serveur $1..."
    execute_remote_commands $1 $2 $3 $4"
        mkdir -p $MOUNT_POINT/3
        echo '${DISK}1 $MOUNT_POINT/3 xfs defaults 0 0' >> /etc/fstab
        mount -a
        mkdir -p $MOUNT_POINT/3/$BRICK_DIR
   "
}

configure_glusterfs_local() {
    # Configure GlusterFS localement pour le point de montage 1
    echo "Configuration de GlusterFS localement pour le point de montage 1..."
    execute_local_commands "
        mkdir -p $MOUNT_POINT/1
        echo '${DISK}1 $MOUNT_POINT/1 xfs defaults 0 0' >> /etc/fstab
        mount -a
        mkdir -p $MOUNT_POINT/1/$BRICK_DIR
    "
}

create_gluster_volume() {
    # Crée un volume GlusterFS localement
    echo "Création d'un volume GlusterFS localement..."
    execute_local_commands "
        gluster volume create gfs \
        replica 3 \
        $REMOTE_HOST1:$MOUNT_POINT/2/$BRICK_DIR \
        $REMOTE_HOST2:$MOUNT_POINT/3/$BRICK_DIR \
        $LOCAL_HOST:$MOUNT_POINT/1/$BRICK_DIR
        gluster volume start gfs
    "
}

mount_gluster_volume() {
    # Monte le volume GlusterFS sur le serveur distant
    echo "Montage du volume GlusterFS sur le serveur distant $1..."
    execute_remote_commands $1 $2 $3 $4"
        echo 'localhost:/gfs /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab
        mount.glusterfs localhost:/gfs /mnt
    "
}

mount_gluster_volume_local() {
    # Monte le volume GlusterFS localement
    echo "Montage du volume GlusterFS localement..."
    execute_local_commands "
        echo 'localhost:/gfs /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab
        mount.glusterfs localhost:/gfs /mnt
    "
}

install_keepalived() {
    # Installe Keepalived sur le serveur distant
    echo "Installation de Keepalived sur le serveur distant $1..."
    execute_remote_commands $1 $2 $3 $4"
       apt install -y keepalived
    "
}

install_keepalived_local() {
    # Installe Keepalived localement
    echo "Installation de Keepalived localement..."
    execute_local_commands "
       apt install -y keepalived
    "
}

configure_keepalived_local() {
    # Configure Keepalived localement
    echo "Configuration de Keepalived localement..."
    execute_local_commands "
    echo -e \"vrrp_instance VI_1 {\n    state MASTER\n    interface $MASTER_INTERFACE\n    virtual_router_id 61\n    priority 255\n    advert_int 1\n    authentication {\n        auth_type PASS\n        auth_pass 12345\n    }\n    virtual_ipaddress {\n        $VIP_IP\n    }\n}\" >> /etc/keepalived/keepalived.conf
  "
}

configure_keepalived1() {
    # Configure Keepalived sur le serveur distant en tant que backup
    echo "Configuration de Keepalived en tant que BACKUP sur le serveur $1..."
    execute_remote_commands $1 $2 $3 $4"
    echo -e \"vrrp_instance VI_1 {\n    state BACKUP\n    interface $WORKER1_INTERFACE\n    virtual_router_id 61\n    priority 255\n    advert_int 1\n    authentication {\n        auth_type PASS\n        auth_pass 12345\n    }\n    virtual_ipaddress {\n        $VIP_IP\n    }\n}\" >> /etc/keepalived/keepalived.conf
    systemctl restart keepalived
  "
}

configure_keepalived2() {
    # Configure Keepalived sur le serveur distant en tant que backup
    echo "Configuration de Keepalived en tant que BACKUP sur le serveur $1..."
    execute_remote_commands $1 $2 $3 $4"
    echo -e \"vrrp_instance VI_1 {\n    state BACKUP\n    interface $WORKER2_INTERFACE\n    virtual_router_id 61\n    priority 255\n    advert_int 1\n    authentication {\n        auth_type PASS\n        auth_pass 12345\n    }\n    virtual_ipaddress {\n        $VIP_IP\n    }\n}\" >> /etc/keepalived/keepalived.conf
    systemctl restart keepalived
  "
}
