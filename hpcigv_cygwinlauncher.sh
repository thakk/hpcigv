# TH
#
# Workstation-side helper script to launch IGV on server from Windows/Cygwin workstation.
#  Modify last lines if this script is used on Linux/Mac machines
#
# TODO;
#  -parametrize

IGVLAUNCHER="/lustre/compbio/pub/apps/hpcigv-1.0/launcher.sh" # Edit this to suit your server environment
GENOMEFILE=""

usage() {
        echo "hpcigv_cygwinlauncher.sh"
        echo " Workstation- side IGV launcher"
        echo " Usage: hpcigv_cygwinlauncher.sh -u <user> -s <server> -l <<localport, default=random>> -c <dir>"
	echo " -c <dir> Use custom jsons in this directory ( default: custom- subdirectory in IGV launcher script directory)"
}

no_args="true"

SERVERUSER=""
SERVER=""
LOCALPORT=`python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()' | tr -d '\r'`  # Remove DOS newline in Cygwin
JSONDIR=""

while getopts "u:s:l:g:c:" arg; do
        case $arg in
                u)
                        SERVERUSER=${OPTARG}
                        ;;
                s)
                        SERVER=${OPTARG}
                        ;;
                l)
                        LOCALPORT=${OPTARG}
                        ;;
		g)
			GENOMEFILE="-g "${OPTARG}
			;;
		c)
			JSONDIR=" -c "${OPTARG}
			;;
                *)
                        usage
                        exit 1
                        ;;
        esac
        no_args="false"
done

[[ "$no_args" == "true" ]] && { usage; exit 1; }

if [ -z "$SERVERUSER" ] || [ -z "$SERVER" ]
then
        echo "Error, both server and user must be provided"
        usage
        exit 1
fi

echo "User: "${SERVERUSER}
echo "Server: "${SERVER}
echo "Local port: "${LOCALPORT}

readonly SERVERPORT=`ssh ${SERVERUSER}@${SERVER} " python -c 'import socket; s=socket.socket(); s.bind((\"\", 0)); print(s.getsockname()[1]); s.close()' "`

echo "Server port: "${SERVERPORT}

echo "Starting IGV on server"
CMD=${IGVLAUNCHER}" -p "${SERVERPORT}" "${GENOMEFILE}" "${JSONDIR}
echo $CMD
ssh -f ${SERVERUSER}@${SERVER} "screen -L -d -m sh -c 'eval ${CMD}'"

sleep 4

echo "Creating ssh tunnel"
ssh -f -N -L ${LOCALPORT}:${SERVER}:${SERVERPORT} ${SERVERUSER}@${SERVER}

echo "Launching firefox."
echo " Note, closing browser window won't stop IGV on server"
sleep 5
#cmd /c "C:\Program Files\Mozilla Firefox\firefox.exe" localhost:${LOCALPORT}
cygstart http://localhost:${LOCALPORT}
read -p "Press any key to close window" x
