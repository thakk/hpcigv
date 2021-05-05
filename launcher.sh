#!/usr/bin/env bash

# IGV launcher script
#
#

CONTAINER=/lustre/compbio/pub/containers/hpcigv.sif # edit this to suit your environment
BINDPATHS=" --bind /lustre:/igv-webapp/dist/lustre --bind /bmt-data:/igv-webapp/dist/bmt-data" # edit this

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

usage() {
	echo "launcher.sh"
	echo " IGV launcher script"
	echo ""
	echo " -p <<port>>	Optional port argument"
	echo "* -d <dir>		Optional dist directory. Used for custom projects"	
	echo " -g <file>	Override default genomes.json with this file"
	echo " -c <dir>	Find custom jsons in this directory ( default: custom- subdirectory in IGV launcher script directory)"

	echo "*	Unimplemented"
}

GENOMESJSON=""
JSONDIR=${SCRIPTPATH}/custom

while getopts "hp:d:c:g:" arg; do
	case $arg in
    	h)
			usage
            exit 0
			;;
		p)
			readonly PORT=${OPTARG}
			;;
		c)
			JSONDIR=${OPTARG}
			;;
		g)
			GENOMESJSON="--bind "${OPTARG}":/igv-webapp/dist/genomes.json"
	esac
done

#if [ -z "$PORT" ]
#then
#	readonly PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
#fi



#singularity exec --bind $HOME/hpcigv/custom:/igv-webapp/dist/custom --bind $HOME/data:/igv-webapp/dist/data --bind /lustre --bind /bmt-data:/igv-webapp/dist/bmt-data  hpcigv.sif npx http-server --port $PORT /igv-webapp/dist
singularity exec --bind ${JSONDIR}:/igv-webapp/dist/custom ${GENOMESJSON} ${BINDPATHS} ${CONTAINER} npx http-server --port $PORT /igv-webapp/dist
