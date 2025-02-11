# Pongo Eraser

Pongo Eraser est un script Bash permettant d'effacer et de formater de manière sécurisée les dispositifs de stockage sur votre système Linux.
Installation

Pour utiliser Pongo Eraser, vous devez disposer d'un système Linux avec les utilitaires nécessaires installés, tels que shred, mkfs.vfat, mkfs.ntfs, mkfs.ext4 et mkfs.exfat. Le script devrait fonctionner sur la plupart des distributions Linux modernes.
Utilisation

    Téléchargez le script pongoEraser.sh sur votre système.

    Ouvrez un terminal et naviguez jusqu'au répertoire contenant le script.

    Exécutez le script avec les privilèges root :

    sudo bash pongoEraser.sh

    Le script listera les dispositifs de stockage disponibles sur votre système.

    Choisissez le dispositif à effacer et sélectionnez la méthode d'effacement souhaitée.

    Le script effacera de manière sécurisée le dispositif sélectionné en utilisant la méthode choisie.

    Une fois l'effacement terminé, le script vous invitera à choisir un format de système de fichiers pour le dispositif.

    Le script formatera le dispositif avec le système de fichiers sélectionné.

## Avertissements

    Données irréversibles : L'effacement des données est permanent et ne peut pas être annulé.
    Sécurité : Veuillez vérifier attentivement le disque que vous sélectionnez avant de procéder à l'effacement. Assurez-vous de ne pas effacer un disque contenant des données importantes.

## Contribuer

Les contributions à Pongo Eraser sont les bienvenues. Si vous trouvez des bugs ou avez des suggestions d'amélioration, n'hésitez pas à ouvrir un problème ou à soumettre une demande de pull sur le dépôt GitHub du projet.
Licence

Pongo Eraser est distribué sous la Licence MIT.
Tests

Pour tester le script Pongo Eraser, vous pouvez l'exécuter sur un dispositif de stockage non critique afin de vérifier son bon fonctionnement. Soyez toujours prudent lors de l'utilisation du script, car il peut effacer de manière permanente les données.
