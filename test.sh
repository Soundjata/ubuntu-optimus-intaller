source /etc/optimus/functions.sh
while getopts g:d:a:c:s:-: option
do
  if [ "$option" = "-" ]
  then
    option="${OPTARG%%=*}"
    OPTARG="${OPTARG#$option}"
    OPTARG="${OPTARG#=}"
  fi
  case "$option" in
    g | generate)
      update_conf DOMAIN $(</dev/urandom tr -dc A-Z0-9 | head -c 16)
    ;;
    d | domain)
      echo $OPTARG
      update_conf DOMAIN $OPTARG
    ;;
    a | ovh-app-key)
      echo $OPTARG
      update_conf OVH_APP_KEY $OPTARG
    ;;
    c | ovh-consumer-key)
      echo $OPTARG
      update_conf OVH_CONSUMER_KEY $OPTARG
    ;;
    s | ovh-secret-key)
      echo $OPTARG
      update_conf OVH_SECRET_KEY $OPTARG
    ;;
    ??* )          
      echo "illegal option --$option"
      exit 2 
    ;;
  esac
done