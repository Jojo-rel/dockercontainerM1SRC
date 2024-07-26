# Configuration pour le script d'installation

# Adresse IP du noeud Docker principal
DOCKER_IP="172.16.0.129"

# --- Noeud 1 ---
# Nom d'hôte local pour le premier noeud
LOCAL_HOST="debian1"

# Interface réseau pour la VIP (Virtual IP) de Keepalived sur le noeud 1
MASTER_INTERFACE="ens36"

# --- Noeud 2 ---
# Adresse IP ou nom d'hôte du deuxième noeud distant
REMOTE_HOST1="debian2"

# Nom d'utilisateur pour la connexion SSH au noeud 2
REMOTE_HOST1_USER="root"

# Interface réseau pour la VIP de Keepalived sur le noeud 2
WORKER1_INTERFACE="ens36"

# --- Noeud 3 ---
# Adresse IP ou nom d'hôte du troisième noeud distant
REMOTE_HOST2="debian3"

# Nom d'utilisateur pour la connexion SSH au noeud 3
REMOTE_HOST2_USER="root"

# Interface réseau pour la VIP de Keepalived sur le noeud 3
WORKER2_INTERFACE="ens36"

# --- Configuration de GlusterFS ---
# Partition à formater pour GlusterFS
DISK="/dev/sdb"

# Point de montage pour les briques GlusterFS
MOUNT_POINT="/gluster/bricks"

# Nom du répertoire de brique pour GlusterFS
BRICK_DIR="brick"

# Adresse IP virtuelle pour Keepalived
VIP_IP="172.16.0.100"

