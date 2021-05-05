#!/usr/bin/env bash

# biosamplestojson.sh 
# Version 0.1
#
# TH,
#
# Finds IGV compatible files from directory and prints filenames in Web IGV conformant json format
#
# Built usuing API 2.0 documentation from https://github.com/igvteam/igv.js/wiki/Tracks-2.0
#
# TODO:
#  - index handling for other than bam files.

REFERENCE="GRCh38"

usage() {
	echo "biosamplestojson.sh"
    echo " Helper script to create IGV conformant json files."
	echo ""
	echo " -d <dir>         Search directory (default=.)"
	echo " -r <reference>   Reference to use (default=GRCh38)"
	echo " -n               Find annotations (bed,gff3,gtf,genePred,genePredExt,peaks,narrowPeak,broadPeak,bigBed,bedpe). Outputs annotations.json"
	echo " -a               Find alignments (bam + bai ). Outputs alignment.json"
    echo " -v               Find variant files ( vcf ). Outputs variant.json"
    echo " -w               Find wig files ( wig ). Outputs wig.json"
    echo " -s               Find segmented copy number tracks ( seg ). Outputs seg.json"
	echo " -j               Find splice junction tracks ( bed, bed.gz + .tbi ). Outputs spliceJunctions.json "
    echo " -g               Find gwas tracks ( bed , gwas). Outputs gwas.json"
	echo " -i               Find interaction tracks ( bedpe ). Outputs interactions.json"
	echo " -m               Find mutation tracks ( mut,maf ). Outputs mut.json"
	echo ""
	
}

#indice meanings; 0==annotation, 1=alignment, 2=variant ,3=wig , 4=segmented copy number, 5=splice junctions , 6=gwas , 7=interaction , 8=mutation
# Strings for find
SEARCHFILES=(
  "\( -name '*bed' -o -name '*gff3' -o -name '*gtf' -o -name '*genePred' -o -name '*genePredExt' -o -name '*peaks' -o -name '*narrowPeak' -o -name '*broadPeak' -o -name '*bigBed' -o -name '*bedpe' \)"
  "-name '*bam'"
  "-name '*vcf'"
  "\( -name '*wig' -o -name '*bigwig'"
  "-name '*seg'"
  "-name '*bed'"
  "\( -name '*bed' -o -name '*gwas' \)"
  "\( -name '*bedpe' -o name '*bedpe.gz \)"
  "\( -name '*mut' -o name '*maf \)"
)

# These names will appear in IGV tracks menu
SEARCHNAMES=(
  "Server Annotations"
  "Server Alignments"
  "Server Variants"
  "Server WIG Tracks"
  "Server Segmented Copy Number"
  "Server Splice Junctions"
  "Server GWAS Tracks"
  "Server Mutations"
)

# IGV internal type definitions used in TRACKs
IGVTYPES=(
  "annotation"
  "alignment"
  "variant"
  "wig"
  "seg"
  "spliceJunctions"
  "gwas"
  "interaction"
  "mut"
)

# $1=type , $2=format, $3=url , $4=name , $5 = directory # old format
# $1=type $2=url , $3=name , $4 = directory
genIGVjsonSampleTrack(){
	BN=`basename $2`
	FILETYPE="${BN##*.}"
	echo "    {"
	echo "      \"type\": \""${IGVTYPES[$1]}"\","
	echo "      \"name\": \""$3"\","
    echo "      \"directory\": \""$4"\","
	echo "      \"url\": \""$2"\"",
	# Redo index finds to account type
	if [ $FILETYPE = "bam" ]; then
		if test -f $2".bai" ; then
			echo "      \"indexURL\": \""$2".bai\","
		else
			echo "Warning, Index file "$2".bai not found" 1>&2 
		fi
	fi
	echo "      \"format\": \""$FILETYPE"\""
	echo "    }"
}

# $1=SEARCHTYPE $2=SEARCHDIR $3=REFERENCE
genIGVjsonMenu(){
	TYPE=$1
	DIR=$2
	REF=$3
	echo "{"
	echo "   \"label\": \""${SEARCHNAMES[$TYPE]}"\","
	echo "   \"description\": \"${SEARCHNAMES[$TYPE]} files found under ${DIR}\","
	echo "   \"genomeID\": \"${REF}\","
	echo "   \"tracks\": ["

	S=${SEARCHFILES[$TYPE]}
	j=0
    CMD="find ${DIR} $S | xargs -I{} dirname {} | sort | uniq | wc -l"
	num_sampledirs=$(eval "$CMD")
	CMD="find ${DIR} $S | xargs -I{} dirname {} | sort | uniq"
	RES=$(eval "$CMD")
	for sampledir in $RES 
	do
		(( j=j+1 ))
		i=0
		CMD="find ${sampledir} -maxdepth 1 $S -exec basename {} \; | wc -l"
		num_samples=$(eval "$CMD")
		CMD="find ${sampledir} -maxdepth 1 $S -exec basename {} \;"
		RESINNER=$(eval "$CMD")
		for sample in $RESINNER
		do
	        (( i=i+1 ))
			genIGVjsonSampleTrack $TYPE ${sampledir}"/"${sample} ${sampledir#"${DIR}"}"/"${sample} ${sampledir#"${DIR}"} 
			if ! [[ $i = $num_samples ]]
	        then
				echo "    ,"
			fi
		done
	    if ! [[ $j = $num_sampledirs ]]
		then
			echo "    ,"
		fi
	done

	echo "  ]"
	echo "}"
}

SEARCHDIR="."
SEARCHTYPES=()
#indice meanings; 0==annotation, 1=alignment, 2=variant ,3=wig , 4=segmented copy number, 5=splice junctions , 6=gwas , 7=interaction , 8=mutation
while getopts "hd:navwsjgim" arg; do
	case $arg in
		d) # searchdir
			SEARCHDIR=${OPTARG}
			;;
        r) # reference
            REFERENCE=${OPTARG}
			;;
		n) # annotations
			SEARCHTYPES+=(0)
			;;
		a) # alignments
			SEARCHTYPES+=(1)
			;;
		v) # variant
			SEARCHTYPES+=(2)
			;;
		w) # wig
			SEARCHTYPES+=(3)
			;;
		s) # segmented copy number
			SEARCHTYPES+=(4)
			;;
		j) # splice junctions
			SEARCHTYPES+=(5)
			;;
		g) # gwas
			SEARCHTYPES+=(6)
			;;
		i) # interaction
			SEARCHTYPES+=(7)
			;;
		m) # mutation
			SEARCHTYPES+=(8)
			;;
		h)
			usage
			exit 0
			;;
		*)
			usage
			exit 1
			;;
	esac
done

if [[ ${#SEARCHTYPES[@]} = 0 ]]
then
	echo "Error; define at least one type of files to find"
	echo ""
	usage
	exit 1
fi

for (( s=0; s<${#SEARCHTYPES[@]} ; s++)); do
    TYPE=${SEARCHTYPES[$s]}
	echo "Outputting "${IGVTYPES[$TYPE]}.json
	genIGVjsonMenu $TYPE $SEARCHDIR $REFERENCE > ${IGVTYPES[$TYPE]}.json
done

