#!/bin/bash
source ./config
DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z]):${TAG}

cd ../181263

# find stata.lic
[[ -z $STATALIC ]] && STATALIC=$(find $HOME/Dropbox/ -name stata.lic.$VERSION| tail -1)
[[ -z $STATALIC ]] && STATALIC=$(find $(pwd)/ -name stata.lic* | sort | tail -1)
[[ -z $STATALIC ]] && STATALIC=$(find $HOME/ -name stata.lic* | sort | tail -1)

if [[ -z $STATALIC ]]
then
        echo "Could not find Stata license"
        grep STATALIC $0
        exit 2
fi

# Directory structure emulates WT

docker run -it --rm \
  -v "${STATALIC}":/usr/local/stata/stata.lic \
	-v "$(pwd)":/home/jovyan/workspace/$MYIMG \
	-w /home/jovyan/workspace/$MYIMG \
	$DOCKERIMG \
	/bin/bash
