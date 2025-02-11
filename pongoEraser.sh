#!/bin/bash

# Vérifier si l'utilisateur est root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Ce script doit être exécuté en root (sudo)."
   exit 1
fi

echo "                     _____ "                
echo " ___ ___ ___ ___ ___|   __|___ ___ ___ ___ "
echo "| . | . |   | . | . |   __|  _| .'|_ -| -_|"
echo "|  _|___|_|_|_  |___|_____|_| |__,|___|___|"
echo "|_|         |___|                          "

# Lister les disques disponibles
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E 'disk'
echo ""

# Demander à l'utilisateur de choisir un disque
read -p "Entrez le nom du disque à formater (ex: sdb) : " DISK
DISK_PATH="/dev/$DISK"

# Vérifier si le disque existe
if [[ ! -b $DISK_PATH ]]; then
    echo "❌ Le disque spécifié n'existe pas."
    exit 1
fi

# Proposer les méthodes de suppression
echo "Méthodes d'effacement sécurisées :"
echo "1)  Remplissage par des zéros (1 passe)"
echo "2)  Remplissage aléatoire (1 passe)"
echo "3)  Air Force 5020(2 passe, 1 aléatoire + 1 zéro)"
echo "4)  Norme NIST 800-88 (1 passe aléatoire)"
echo "5)  Norme HMG IS5 (3 passes : 1 zéro + 1 aléatoire + 1 zéro)"
echo "6)  Standard DoD 5220.22-M ECE (7 passes)"
echo "7)  Méthode Gutmann (35 passes, ultra-sécurisée)"
echo "8)  Méthode ANSSI (3 passes : 1 aléatoire + 1 zéro + 1 aléatoire)"
echo "9)  ssd secure erase"
read -p "Choisissez une méthode (1-9) : " METHOD

# Définir la commande shred avec affichage de la progression
echo "???? Effacement en cours..."
case $METHOD in
    1) shred -n 0 -z -v $DISK_PATH;;
    2) shred -n 1 -v $DISK_PATH;;
    3) shred -n 1 -Z -v $DISK_PATH;; # Norme AIRFORCE
    4) shred -n 1 -v $DISK_PATH;; # Norme NIST 800-88
    5) shred -n 0 -z -v $DISK_PATH && shred -n 1 -v $DISK_PATH && shred -n 0 -Z -v $DISK_PATH;; # Norme HMG IS5
    6) shred -n 7  -v $DISK_PATH;;
    7) shred -n 35 -v $DISK_PATH;;
    8) shred -n 1 -v $DISK_PATH && shred -n 0 -z -v $DISK_PATH && shred -n 1 -v $DISK_PATH;; # Norme ANSSI
    9) blkdiscard -f $DISK_PATH;;
    *) echo "❌ Option invalide."; exit 1;;
esac

echo "✅ Effacement sécurisé terminé."

# Proposer un formatage
echo "\nFormats disponibles :"
echo "1) FAT32"
echo "2) NTFS"
echo "3) EXT4"
echo "4) exFAT"
read -p "Choisissez un format (1-4) : " FORMAT

case $FORMAT in
    1) mkfs.vfat -F 32 $DISK_PATH; FSTYPE="FAT32";;
    2) mkfs.ntfs -f $DISK_PATH; FSTYPE="NTFS";;
    3) mkfs.ext4 $DISK_PATH; FSTYPE="EXT4";;
    4) mkfs.exfat $DISK_PATH; FSTYPE="exFAT";;
    *) echo "❌ Option invalide."; exit 1;;
esac

echo "✅ Le disque a été formaté en $FSTYPE avec succès !"
