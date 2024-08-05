#!/bin/bash
# Frontend to tool_qstreamflow for querying list of IP Addresses
# use this if agency is requesting dozens of IP at once 


#
# Read the XML file for value args=configfile,tagelement
get_config_value(){
  FILE=$1
  TAG_ELEMENT=$2
  a=$(grep -o "</$TAG_ELEMENT>" $FILE | wc -l)
  b=$(awk -v n=$a "BEGIN{RS=\"</$TAG_ELEMENT>\n\";ORS=RS} NR<=n" $FILE | sed -n "/<$TAG_ELEMENT>/,/<\/$TAG_ELEMENT>/p")
  b=$(echo $b | grep -o -P "(?<=<$TAG_ELEMENT>).*(?=</$TAG_ELEMENT>)")
  echo $b | sed -e "s/<\/$TAG_ELEMENT>.*<$TAG_ELEMENT>\s*/\n/g"
}

usage()
{
  echo "Usage: $0 [ -c hub-config-xml-file | default=default-hub-xml] [ -f From Date DD-MM-YYYY(-HH:MM)] [ -t To DATE DD-MM-YYYY(-HH:MM) ] [-i list-of-ip-file ]" 1>&2
  echo "Examples  $0 -f 25-12-2024 -t 26-12-2024 -i list-of-ips1.txt"
  echo "Examples  $0 -f 25-12-2024-14:30 -t 26-12-2024-15:30  -i list-of-ips1.txt"
}

exit_abnormal()
{ 
  usage
  exit 1
}

if [[ $# -eq 0 ]] ; then
  exit_abnormal
fi

source ./env.eff

#DEFAULTS
INPUTFILE=""
PRINTONLY=false
VERBOSE=false
OUTDIR=/tmp
SQLITE3_HUB_SHELL="/usr/local/bin/sqlite3_hub_shell"
TRISUL_HUB_CONFIG=$INSTALL_PREFIX/etc/trisul-hub/domain0/hub0/context0/trisulHubConfig.xml

while getopts "i:o:c:f:t:PV" options; do

  case "${options}" in
    c)
     TRISUL_HUB_CONFIG="${OPTARG}"
      ;;
    f) 
      START_DATE_TIME="${OPTARG}"
      ;;
    t) 
      END_DATE_TIME="${OPTARG}"
      ;;
    i)
      INPUTFILE="${OPTARG}"
      ;;
    P)
      PRINTONLY=true
      ;;
    V)
      VERBOSE=true
      ;;
    :)
      echo "Error: -"${OPTARG}" requires an argument."
      exit_abnormal
      ;;
    *)
      exit_abnormal
      ;;
  esac
done

if [ -z "$START_DATE_TIME" ] ; then
  echo "Missing from date -f"
  usage
  exit 1
fi

if [ -z "$END_DATE_TIME" ] ; then
  echo "Missing to date -t"
  usage
  exit 1
fi

if [ -z "$INPUTFILE" ] ; then
  echo "Input file containing list of IP one per line must be specified "
  usage
  exit 1
fi 

if [ ! -f "$INPUTFILE" ] ; then
  echo "Input file with list of IP : $INPUTFILE not found"
  usage
  exit 1
fi 


# Check if context is valid
if [ ! -f "$TRISUL_HUB_CONFIG" ]; then
  echo "Source trisulHubConfig.xml file does not exist in $TRISUL_HUB_CONFIG"
  exit 1
fi



EPOCH=$(date +%s)
OUTDIR="$OUTDIR/ipdrresults-$EPOCH"
mkdir -p $OUTDIR 
echo "Writing output files to directory $OUTDIR"
while read -r ip1
do
  if [[ ! -z $ip1 ]] && [[ $ip1 =~ ^[0-9\\.]*$ ]]  
  then 
	echo "Querying IP $ip1"
	STARTSECS=$SECONDS
	/usr/local/bin/tool_qstreamflow -f $START_DATE_TIME  -t $END_DATE_TIME  -c $TRISUL_HUB_CONFIG --report-format trai --lookup-userid  -i $ip1 -o $OUTDIR/queryresults.$ip1 
	ELAPSED=$(( $SECONDS - $STARTSECS ))
	echo "Finished IP $ip1 in $ELAPSED seconds "
  else
	echo "Skipping invalid IP address in file : $ip1"
  fi


done < "$INPUTFILE"

echo "Check results directory : $OUTDIR" 


