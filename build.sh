#!/bin/bash

# reading configuration


# if we are on Github Actions
if [[ $CI ]] 
then
   DOCKERIMG=$(echo $GITHUB_REPOSITORY | tr [A-Z] [a-z])
   TAG=latest
else
   source init.config.txt
   DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z])
fi


# for debugging
BUILDARGS="--progress plain --no-cache"



DOCKER_BUILDKIT=1 docker build \
  $BUILDARGS \
  . \
  -t ${DOCKERIMG}:$TAG

if [[ $? == 0 ]]
then
   # write out final values to config
   [[ -f config ]] && \rm -i config
   echo "# configuration created on $(date +%F_%H:%M)" | tee config
   for name in $(grep -Ev '^#' init.config.txt| awk -F= ' { print $1 } ')
   do 
      echo ${name}=${!name} >> config
   done
fi

      
      
   
