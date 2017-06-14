#!/bin/bash

set -e
cd `dirname $0`

function container_full_name() {
    # Retourne le nom complet du coneneur $1 si il est en cours d'exécution
    # workaround for docker-compose ps: https://github.com/docker/compose/issues/1513
    ids=$(docker-compose ps -q)
    if [ "$ids" != "" ] ; then
        echo `docker inspect -f '{{if .State.Running}}{{.Name}}{{end}}' $ids \
              | cut -d/ -f2 | grep -E "_${1}_[0-9]"`
    fi
}

function dc_dockerfiles_images() {
    # Retourne la liste d'images Docker depuis les Dockerfile build listés dans docker-compose.yml
    local DOCKERDIRS=`grep -E '^\s*build:' docker-compose.yml|cut -d: -f2 |xargs`
    local dockerdir
    for dockerdir in $DOCKERDIRS; do
        echo `grep "^FROM " ${dockerdir}/Dockerfile |cut -d' ' -f2|xargs`
    done
}

function dc_exec_or_run() {
    # Lance la commande $2 dans le container $1, avec 'exec' ou 'run' selon si le conteneur est déjà lancé ou non
    local options=
    while [[ "$1" == -* ]] ; do
        options="$options $1"
        shift
    done
    local CONTAINER_SHORT_NAME=$1
    local CONTAINER_FULL_NAME=`container_full_name ${CONTAINER_SHORT_NAME}`
    shift
    if test -n "$CONTAINER_FULL_NAME" ; then
        # container already started
        docker exec -it $options $CONTAINER_FULL_NAME "$@"
    else
        # container not started
        docker-compose run --rm $options $CONTAINER_SHORT_NAME "$@"
    fi
}

case $1 in
    "")
        test -e docker-compose.yml || (echo "ERREUR: fichier docker-compose.yml manquant"; exit -1)
        docker-compose up -d
        ;;
    upgrade)
        read -rp "Êtes-vous sûr de vouloir effacer et mettre à jour les images et conteneurs Docker ? (o/n) "
        if [[ $REPLY =~ ^[oO]$ ]] ; then
            docker-compose pull
            for image in `dc_dockerfiles_images`; do
                docker pull $image
            done
            docker-compose build
            docker-compose stop
            $0
        fi
        ;;
    prune)
        read -rp "Êtes-vous sûr de vouloir effacer les conteneurs et images Docker innutilisés ? (o/n)"
        if [[ $REPLY =~ ^[oO]$ ]] ; then
            # Note: la commande docker system prune n'est pas dispo sur les VPS OVH
            # http://stackoverflow.com/questions/32723111/how-to-remove-old-and-unused-docker-images/32723285
            exited_containers=$(docker ps -qa --no-trunc --filter "status=exited")
            test "$exited_containers" != ""  && docker rm $exited_containers
            dangling_images=$(docker images --filter "dangling=true" -q --no-trunc)
            test "$dangling_images" != "" && docker rmi $dangling_images
        fi
        ;;
    sh)
        dc_exec_or_run dokuwiki "$@"
        ;;
    build|config|create|down|events|exec|kill|logs|pause|port|ps|pull|restart|rm|run|start|stop|unpause|up)
        docker-compose "$@"
        ;;
    *)
        cat <<HELP
Utilisation : $0 [COMMANDE]
               : lance le conteneur
  upgrade      : met à jour les images et les conteneurs Docker
  prune        : efface les conteneurs et images Docker inutilisés
  sh           : lance sh sur le conteneur odoo
  stop         : stope les conteneurs
  rm           : efface les conteneurs
  logs         : affiche les logs des conteneurs
HELP
        ;;
esac

