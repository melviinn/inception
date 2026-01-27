_This project has been created as part of the 42 curriculum by mduchauf._

# Description

<br>
<br>

# Instructions

<br>
<br>

# Resources

## Links

#### This is the resources that I used to get started with the subjects and get all the requirements

- [Official Docker website](https://docs.docker.com)

- [List of Docker commands & instructions](https://gist.github.com/jpchateau/4efb6ed0587c1c0e37c3)

- [Youtube Docker tutorial](https://www.youtube.com/watch?v=pTFZFxd4hOI)

## AI Utilisation

- I used AI to install the required docker packages (docker.io & docker-compose)

<br>
<br>

# Project description

### Virtual Machines VS Docker:

Utiliser docker est plus _leger_ que de devoir embarquer un systeme d'exploitation complet. Ici le conteneur Docker partage le noyau de la machine (Linux, Windows...), il "transporte" uniquement le necessaire (l'application et ses dependances).

#### Comparatif VM et Docker:

| Critère       | Machine virtuelle                   | Conteneur Docker             |
| :------------ | :---------------------------------- | :--------------------------- |
| Démarrage     | Minutes (boot complet de l’OS)      | Secondes (simple processus)  |
| Taille disque | Gigaoctets (OS complet)             | Mégaoctets (app seule)       |
| Mémoire RAM   | Réservée en bloc (ex: 4 Go minimum) | Partagée dynamiquement       |
| Isolation     | Complète (hyperviseur matériel)     | Processus (namespaces Linux) |
| Densité       | 10-20 VM par serveur                | Centaines de conteneurs      |
| Portabilité   | Moyenne (format VM propriétaire)    | Excellente (standard OCI)    |

---

### Secrets VS Environments Variables

---

### Docker Network VS Host Network

---

### Docker Volumes VS Bind Mounts

---
