#!/bin/bash
# Frontend to tool_qstreamflow for correlating and querying by user ID 


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
  echo "Usage: $0 [ -d domain(default domain0) ] [ -n node(default hub0) ] [ -c CONTEXT(default context0) ]  [ -f From Date DD-MM-YYYY  ] [ -t To DATE Date DATE DD-MM-YYYY] [-u userid]" 
  echo "Examples  $0 -f 25-12-2024 -t 26-12-2024 -u MarkJenny123"
  echo "Examples  $0 -f 25-12-2024-14:30 -t 26-12-2024-15:30  -u MarkJenny123"
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
DOMAIN="domain0"
NODE="hub0"
CONTEXT="context0"
USERID=""
SUBID=""
PRINTONLY=false
VERBOSE=false
SQLITE3_HUB_SHELL="/usr/local/bin/sqlite3_hub_shell"

while getopts "d:n:c:u:s:f:t:PV" options; do

  case "${options}" in
    d)
      DOMAIN="${OPTARG}"
      ;;
    n)
      NODE="${OPTARG}"
      ;;
    c)
      CONTEXT="${OPTARG}"
      ;;
    f) 
      START_DATE="${OPTARG}"
      ;;
    t) 
      END_DATE="${OPTARG}"
      ;;
    u)
	  USERID="${OPTARG}"
	  ;;
	s)
	  SUBID="${OPTARG}"
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

if [ -z "$START_DATE" ] ; then
  echo "Missing from date -f"
  usage
  exit 1
fi

if [ -z "$END_DATE" ] ; then
  echo "Missing to date -t"
  usage
  exit 1
fi

if [ -z "$USERID" ] &&  [ -z "$SUBID" ]; then
  echo "User ID or Subscriber ID -u or -s must be specified"
  usage
  exit 1
fi 

if [ ! -z "$USERID" ] && [ ! -z "$SUBID" ]; then
  echo "Both User ID or Subscriber ID cannot be specified" 
  usage
  exit 1
fi 

TRISUL_CONTEXT=$CONTEXT

if [ $CONTEXT == 'default' ] || [ $CONTEXT == 'context0' ]; then
  TRISUL_CONTEXT="context0"
else
  TRISUL_CONTEXT="context_$CONTEXT"
fi

# Check if context is valid
TRISUL_HUB_CONFIG=$INSTALL_PREFIX/etc/trisul-hub/$DOMAIN/$NODE/$TRISUL_CONTEXT/trisulHubConfig.xml
if [ ! -f "$TRISUL_HUB_CONFIG" ]; then
  echo "Source trisulHubConfig.xml file does not exist in $TRISUL_HUB_CONFIG"
  exit 1
fi

if [ ! -f "$SQLITE3_HUB_SHELL" ]; then
	SQLITE3_HUB_SHELL="/usr/bin/sqlite3"
	if [ ! -f "$SQLITE3_HUB_SHELL" ]; then
		echo "sql hub shell does not exists in $SQLITE3_HUB_SHELL"
		exit 1
	fi 
fi

TRAFFIC_DB_ROOT=$(get_config_value $TRISUL_HUB_CONFIG "TrafficDBRoot") 
META_SLICE_PATH="$TRAFFIC_DB_ROOT/METASLICE.SQDB"

if [ ! -f "$META_SLICE_PATH" ]; then
  echo "METASLICES not found in $META_SLICE_PATH"
  exit 1
fi


AAADB_PATH_ARRAY=()
DATE=$(date -d $START_DATE +%Y-%m-%d)
until [[ $START_DATE > $END_DATE ]]; do 
  SQL_STRING="SELECT STATUS, OPERINSTANCE, NAME, datetime(FIRST_FLUSH_TS, 'unixepoch', 'localtime') as FROM_TIME from SLICES where strftime('%Y-%m-%d', FROM_TIME)='"$DATE"' AND OPERINSTANCE='0' order by id desc"
  while read row1; do
    IFS='|' read -r -a array <<< "$row1"
    if [[ ${array[0]} == "oper" ]]; then
		slice_path="${array[0]}/${array[1]}/${array[2]}"
    else
		slice_path="${array[0]}/${array[2]}"
    fi

	aaadb_path="$TRAFFIC_DB_ROOT/$slice_path/IPDR/AAALOG.SQDB"
    AAADB_PATH_ARRAY+=("$aaadb_path")
  done < <($SQLITE3_HUB_SHELL $META_SLICE_PATH "$SQL_STRING")
  START_DATE=$(date -I -d "$START_DATE + 1 day")
  DATE=$(date -d $START_DATE +%Y-%m-%d)
done

if [ ${#AAADB_PATH_ARRAY[@]} -eq 0 ]; then
  echo "No AAA databases found for the given input"
fi

	

# Get the lease information for user 
leases=()
for aaadb in "${AAADB_PATH_ARRAY[@]}"
do
		if $VERBOSE; then
		   printf $aaadb
		fi 

  if [ -z "$SUBID" ]; then 
	  USER_QUERY_STRING="attach database ':memory:' as M1; create table M1.leases as select * from TRISUL_IP_AAA where userid='"$USERID"'; select ipaddr, min(lease_start), max(lease_end), userid,full_record  from M1.leases group by ipaddr;"
  else
	  USER_QUERY_STRING="attach database ':memory:' as M1; create table M1.leases as select * from TRISUL_IP_AAA where full_record='"$SUBID"'; select ipaddr, min(lease_start), max(lease_end), userid,full_record  from M1.leases group by ipaddr;"
  fi 
		 

  while read row1; do
    IFS='|' read -r -a array <<< "$row1"

	i=${array[0]}
	f=$(date -d @${array[1]} +%d-%m-%Y-%H:%M) 
	t=$(date -d @${array[2]} +%d-%m-%Y-%H:%M)
	u=${array[3]}
	s=${array[4]}
	leases+=("$i^$f^$t^$u^$s")
  done < <($SQLITE3_HUB_SHELL $aaadb "$USER_QUERY_STRING")
done


# Print the lease table 
echo "------------------------------------------------------------------------------------------------------------------"  
TITLES=(IP LeaseStart LeaseEnd UserID SubscriberID)
printf "%-20s%-25s%-25s%-30s%-20s\n"  ${TITLES[0]} ${TITLES[1]} ${TITLES[2]} ${TITLES[3]} ${TITLES[4]}     
echo "------------------------------------------------------------------------------------------------------------------"  
for lease in "${leases[@]}"
do

  IFS='^' read -r -a larr <<< "$lease"

  printf "%-20s%-25s%-25s%-30s%-20s\n"  ${larr[0]} ${larr[1]} ${larr[2]} ${larr[3]} ${larr[4]}     

done 

echo "------------------------------------------------------------------------------------------------------------------"  

if $PRINTONLY; then
	exit 0
fi


# Run the tool for each lease time 
for lease in "${leases[@]}"
do

  IFS='^' read -r -a larr <<< "$lease"

  printf "%-20s%-25s%-25s%-30s%-20s\n"  ${larr[0]} ${larr[1]} ${larr[2]} ${larr[3]} ${larr[4]}     

  /usr/local/bin/tool_qstreamflow -f ${larr[1]}  -t ${larr[2]}  -c /usr/local/etc/trisul-hub/domain0/hub0/context0/trisulHubConfig.xml --report-format trai --lookup-userid  -i ${larr[0]} --subid-hath-bb
done 

