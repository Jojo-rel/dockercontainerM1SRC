# DockerStackM1SRC

Ce dépôt contient des scripts pour déployer automatiquement une stack Docker incluant Docker Swarm, GlusterFS et Keepalived sur 3 nœuds.

## Auteurs
Simon Gressard | Jonathan Ortega | Deguy Mégane

## Github

Lien GitHub public : [https://github.com/Jojo-rel/dockercontainerM1SRC.git](https://github.com/Jojo-rel/dockercontainerM1SRC.git)

# Sommaire
1. [Applications déployées dans la stack docker](#Applications-déployées-dans-la-stack-docker)
2. [Configuration](#configuration)
3. [Utilisation des Scripts](#utilisation-des-scripts)
   - [Étapes à Suivre](#étapes-à-suivre)
   - [Exemple](#Exemple)

# Applications déployées dans la stack docker

## Grafana
- **Port**: 3000
- **Dashboard**: Marketplace Grafana, voir fichier `./project/grafana/11600_rev1.json` (a été chargé directement depuis l'interface GUI de Grafana)
- **Source monitoring**: Prometheus

## Prometheus
- **Port**: 9090

## Cadvisor
- **Port**: 8005

## Alertmanager
- **Port**: 9093
  
## Wordpress
- **Port**: 80
  
# Configuration

Avant d'exécuter les scripts, vous devez configurer les variables dans le fichier `config.sh`. Voici les variables à modifier :

- **`DOCKER_IP`** : 
  - **Description** : L'adresse IP du nœud Docker principal.
  - **Exemple** : `DOCKER_IP="172.16.0.129"`

- **`LOCAL_HOST`** : 
  - **Description** : Le nom d'hôte du nœud local.
  - **Exemple** : `LOCAL_HOST="debian1"`

- **`REMOTE_HOST1` et `REMOTE_HOST2`** : 
  - **Description** : Les noms d'hôtes des nœuds distants.
  - **Exemple** :
    `REMOTE_HOST1="debian2"`
    `REMOTE_HOST2="debian3"`

- **`REMOTE_HOST1_USER` et `REMOTE_HOST2_USER`** : 
  - **Description** : Les noms d'utilisateur pour la connexion SSH aux nœuds distants.
  - **Exemple** :
    `REMOTE_HOST1_USER="root"`
    `REMOTE_HOST2_USER="root"`

- **`MASTER_INTERFACE`, `WORKER1_INTERFACE`, et `WORKER2_INTERFACE`** : 
  - **Description** : Les interfaces réseau pour les VIP (Virtual IP) de Keepalived sur chaque nœud.
  - **Exemple** :
    `MASTER_INTERFACE="ens36"`
    `WORKER1_INTERFACE="ens36"`
    `WORKER2_INTERFACE="ens36"`

- **`DISK`** : 
  - **Description** : La partition à formater pour GlusterFS.
  - **Exemple** : `DISK="/dev/sdb"`

- **`MOUNT_POINT`** : 
  - **Description** : Le point de montage pour les briques GlusterFS.
  - **Exemple** : `MOUNT_POINT="/gluster/bricks"`

- **`BRICK_DIR`** : 
  - **Description** : Le nom du répertoire de brique pour GlusterFS.
  - **Exemple** : `BRICK_DIR="brick"`

- **`VIP_IP`** : 
  - **Description** : L'adresse IP virtuelle pour Keepalived.
  - **Exemple** : `VIP_IP="172.16.0.100"`

# Utilisation des Scripts

Cette section explique comment utiliser les scripts fournis pour déployer les stacks docker.

## Étapes à Suivre

1. **Accéder au Répertoire des Scripts** :
   Ouvrez votre terminal et naviguez jusqu'au répertoire contenant les scripts :

   `cd /chemin/vers/le/répertoire/des/scripts`

2. **Vérifier que les Scripts sont au Bon Format** :
   Si les scripts ont été modifiés sous Windows, exécutez la commande suivante pour convertir les fichiers au format Unix :

   `dos2unix *.sh`

3. **Rendre les Scripts Exécutables** :
   Assurez-vous que tous les scripts ont les permissions d'exécution nécessaires en utilisant la commande suivante :

   `chmod +x *.sh`

4. **Ordre de Lancement des Scripts** :
   Suivez cet ordre pour exécuter les scripts :
   - `install.sh` : Déploie Docker Swarm, GlusterFS, et Keepalived.
   - `setup.sh` : Déploie la stack Docker.
   - `cleanup.sh` : Supprime la stack Docker si nécessaire.

5. **Exécuter le Script Principal** :
   Pour démarrer l'installation et la configuration, exécutez le script `install.sh` :

   `./install.sh`

6. **Surveiller l'Exécution** :
   Pendant l'exécution du script, surveillez la sortie pour vérifier que chaque étape s'est déroulée correctement. En cas d'erreurs, consultez les messages affichés dans le terminal.

7. **Vérifier l'Installation** :
   Une fois le script terminé, vérifiez que Docker, GlusterFS, et Keepalived sont correctement installés et configurés sur tous les nœuds. Utilisez les commandes suivantes pour vérifier :

   Pour Docker :
   `docker --version`

   Pour GlusterFS :
   `gluster --version`

   Pour Keepalived :
   `systemctl status keepalived`

8. **Vérifier les Nœuds Docker** :
   Pour vérifier l'état des nœuds Docker Swarm, utilisez les commandes suivantes :

   - Pour afficher la liste des nœuds Docker Swarm :
     `docker node ls`

   - Pour vérifier les services Docker en cours d'exécution :
     `docker service ls`

## Exemple

Voici un exemple de la façon dont vous pourriez exécuter les scripts dans votre terminal :

   - `cd /path/to/your/scripts`
   - `dos2unix *.sh`
   - `chmod +x *.sh`
   - `./install.sh`
