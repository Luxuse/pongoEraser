#!/bin/bash

# Vérifier si l'utilisateur est root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Ce script doit être exécuté en root (sudo)."
   exit 1
fi

required_commands=("shred" "lsblk" "mkfs.vfat" "mkfs.ntfs" "mkfs.ext4" "mkfs.exfat" "blkdiscard")
for cmd in "${required_commands[@]}"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "❌ La commande $cmd est requise mais n'est pas installée."
    exit 1
  fi
done

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
echo "3) Afficher l'aide"
echo "4) Quitter"
read -p "Choisissez une option (1-4) : " CHOICE

case $CHOICE in
  3)
    echo "Ce script permet d'effacer de manière sécurisée des disques, fichiers ou dossiers."
    echo "Options disponibles :"
    echo "1) Effacer un disque : Efface tout le contenu d'un disque."
    echo "2) Effacer un fichier ou dossier : Efface un fichier ou dossier spécifique."
    echo "3) Afficher l'aide : Affiche cette aide."
    echo "4) Quitter : Quitte le script."
    exit 0
    ;;
  4) echo "Au revoir !"; exit 0;;
  1)
    # Lister les disques disponibles
    echo "Disques disponibles :"
    lsblk -o NAME,SIZE,TYPE,MODEL,VENDOR,MOUNTPOINT | grep -E 'disk'
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

  function estimate_time {
  local size=$(lsblk -bno SIZE "$DISK_PATH")
  local speed=50000000 # Vitesse estimée d'effacement en octets par seconde (50 MB/s)
  local passes=$1
  # Utilisation de bc pour effectuer les calculs avec de grands nombres
  local total_time=$(echo "$size / $speed * $passes" | bc)
  local minutes=$(echo "$total_time / 60" | bc)
  echo "Temps estimé : $minutes minutes"
}




    estimate_time $METHOD

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

    LOG_FILE="${SCRIPT_DIR}/effacement.log"

    log_message() {
      local message="$1"
      echo "$(date +"%Y-%m-%d %H:%M:%S") : $message" >> "$LOG_FILE"
    }

    # Ajouter des journaux dans le script
    log_message "Début de l'effacement pour $DISK_PATH avec la méthode $METHOD_NAME."
    if [ $? -eq 0 ]; then
      log_message "Effacement réussi pour $DISK_PATH."
    else
      log_message "Une erreur est survenue pendant l'effacement de $DISK_PATH."
    fi

    if [ $? -eq 0 ]; then
      END_TIME=$(date)
      echo "✅ Effacement terminé avec succès."

      # Génération du certificat
      TIMESTAMP=$(date +"%Y%m%d%H%M%S")
      CERTIFICATE="${CERT_DIR}/certificat_effacement_${DISK}_${TIMESTAMP}.txt"
      {
        echo "============================="
        echo "  CERTIFICAT D'EFFACEMENT  "
        echo "============================="
        echo "Disque : $DISK_PATH"
        echo "Méthode d'effacement : $METHOD_NAME"
        echo "Début : $START_TIME"
        echo "Fin : $END_TIME"
        echo "Utilisateur : $(whoami)"
        echo "Machine : $(hostname)"
        echo "Signature SHA256 :"
        sha256sum "$CERTIFICATE"
      } > "$CERTIFICATE"
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

    exit 0
    ;;

  *)
    echo "❌ Option invalide."
    exit 1
    ;;
esac
