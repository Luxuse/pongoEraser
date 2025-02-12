#!/bin/bash

# Vérifier si l'utilisateur est root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Ce script doit être exécuté en root (sudo)."
   exit 1
fi

# Récupérer l'emplacement du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="${SCRIPT_DIR}/certificats_effacement"
mkdir -p "$CERT_DIR"

echo "                     _____ "                
echo " ___ ___ ___ ___ ___|   __|___ ___ ___ ___ "
echo "| . | . |   | . | . |   __|  _| .'|_ -| -_|"
echo "|  _|___|_|_|_  |___|_____|_| |__,|___|___|"
echo "|_|         |___|                          "

echo "====================="
echo "  Effacement sécurisé  "
echo "====================="
echo "1) Effacer un disque"
echo "2) Effacer un fichier ou dossier"
read -p "Choisissez une option (1-2) : " CHOICE

case $CHOICE in
  1)
    # Lister les disques disponibles
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E 'disk'
    echo ""
    read -p "Entrez le nom du disque à formater (ex: sdb) : " DISK
    DISK_PATH="/dev/$DISK"
    
    if [[ ! -b $DISK_PATH ]]; then
      echo "❌ Le disque spécifié n'existe pas."
      exit 1
    fi
    
    echo "⚠️  AVERTISSEMENT : Toutes les données seront perdues !"
    read -p "Êtes-vous sûr ? (oui/non) : " CONFIRM
    if [[ "$CONFIRM" != "oui" ]]; then
      echo "❌ Opération annulée."
      exit 1
    fi
    
    echo "Méthodes d'effacement sécurisées :"
    echo "1) Remplissage par des zéros (1 passe)"
    echo "2) Remplissage aléatoire (1 passe)"
    echo "3) Air Force 5020 (2 passes)"
    echo "4) Norme NIST 800-88 (1 passe aléatoire)"
    echo "5) Norme HMG IS5 (3 passes)"
    echo "6) Standard DoD 5220.22-M ECE (7 passes)"
    echo "7) Méthode Gutmann (35 passes)"
    echo "8) Méthode ANSSI (3 passes)"
    echo "9) SSD Secure Erase"
    read -p "Choisissez une méthode (1-9) : " METHOD

    # Déterminer le nom de la méthode choisie
    case $METHOD in
      1) METHOD_NAME="Remplissage par des zéros (1 passe)";;
      2) METHOD_NAME="Remplissage aléatoire (1 passe)";;
      3) METHOD_NAME="Air Force 5020 (2 passes)";;
      4) METHOD_NAME="Norme NIST 800-88 (1 passe aléatoire)";;
      5) METHOD_NAME="Norme HMG IS5 (3 passes)";;
      6) METHOD_NAME="Standard DoD 5220.22-M ECE (7 passes)";;
      7) METHOD_NAME="Méthode Gutmann (35 passes)";;
      8) METHOD_NAME="Méthode ANSSI (3 passes)";;
      9) METHOD_NAME="SSD Secure Erase";;
      *) echo "❌ Option invalide."; exit 1;;
    esac

    START_TIME=$(date)
    echo "⏳ Effacement en cours..."
    case $METHOD in
      1) shred -n 0 -z -v $DISK_PATH;;
      2) shred -n 1 -v $DISK_PATH;;
      3) shred -n 1 -z -v $DISK_PATH;;
      4) shred -n 1 -v $DISK_PATH;;
      5) (shred -n 0 -z -v $DISK_PATH && shred -n 1 -v $DISK_PATH && shred -n 0 -z -v $DISK_PATH);;
      6) shred -n 7 -v $DISK_PATH;;
      7) shred -n 35 -v $DISK_PATH;;
      8) (shred -n 1 -v $DISK_PATH && shred -n 0 -z -v $DISK_PATH && shred -n 1 -v $DISK_PATH);;
      9) blkdiscard -f $DISK_PATH;;
      *) echo "❌ Option invalide."; exit 1;;
    esac
    
    if [ $? -eq 0 ]; then
      
         END_TIME=$(date)
    echo "✅ Effacement terminé avec succès."
    
    # Génération du certificat
    TIMESTAMP=$(date +"%Y%m%d%H%M%S")
    CERTIFICATE="${CERT_DIR}/certificat_effacement_${DISK}_${TIMESTAMP}.txt"
    echo "=============================" > "$CERTIFICATE"
    echo "  CERTIFICAT D'EFFACEMENT  " >> "$CERTIFICATE"
    echo "=============================" >> "$CERTIFICATE"
    echo "Disque : $DISK_PATH" >> "$CERTIFICATE"
    echo "Méthode d'effacement : $METHOD_NAME" >> "$CERTIFICATE"
    echo "Début : $START_TIME" >> "$CERTIFICATE"
    echo "Fin : $END_TIME" >> "$CERTIFICATE"
    echo "Utilisateur : $(whoami)" >> "$CERTIFICATE"
    echo "Machine : $(hostname)" >> "$CERTIFICATE"
    echo "Signature SHA256 :" >> "$CERTIFICATE"
    sha256sum "$CERTIFICATE" >> "$CERTIFICATE"
    echo "✅ Certificat enregistré : $CERTIFICATE"
    

    else
      echo "❌ Une erreur est survenue pendant l'effacement."
    fi
    
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
    echo "✅ Formatage en $FSTYPE terminé."
    ;;

  2)
    read -p "Entrez le chemin du fichier ou dossier à effacer : " FILE_PATH
    if [[ ! -e $FILE_PATH ]]; then
      echo "❌ Le fichier ou dossier spécifié n'existe pas."
      exit 1
    fi
    
    echo "Méthodes d'effacement sécurisées :"
echo "Choisissez le nombre de passages souhaité :"
read -p "Choisissez le nombre de passages (1-35) : " METHOD_FILE

echo "⚠️ AVERTISSEMENT : Cette action est irréversible !"
read -p "Êtes-vous sûr ? (oui/non) : " CONFIRM_FILE

if [[ "$CONFIRM_FILE" != "oui" ]]; then
  echo "❌ Opération annulée."
  exit 1
fi

if [[ -d $FILE_PATH ]]; then
  find "$FILE_PATH" -type f -exec shred -n "$METHOD_FILE" -v {} \;
  rm -rf "$FILE_PATH"
else
  shred -n "$METHOD_FILE" -v "$FILE_PATH"
  rm -f "$FILE_PATH"
fi

if [ $? -eq 0 ]; then
  echo "✅ Effacement terminé avec succès."
else
  echo "❌ Une erreur est survenue pendant l'effacement."
fi


 
   
    exit 1
    ;;
esac
