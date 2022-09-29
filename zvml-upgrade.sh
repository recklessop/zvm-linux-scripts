#!/bin/bash

# create directory for upgrade script
mkdir /opt/zerto/zlinux/upgrade

# write upgrade script into a file
cat > /opt/zerto/zlinux/upgrade/upgrade.bash<< EOF

# private qa environment: ./upgrade.bash --v 9.5.20.185 --qa --folder private
# public qa environment: ./upgrade.bash --v 9.5.20.185 --qa
# for official release (prod): ./upgrade.bash --v 9.5.20
log_error(){
    local red=$(tput setaf 1)
    local reset=$(tput sgr0)
    echo -e "${red}$@${reset}"
}

while [ $# -gt 0 ]; do
    if [[ $1 == "--qa" ]]; then
        ENVIRONMENT=qa
    elif [[ $1 == "--folder" ]]; then
        FOLDER=$2
    elif [[ $1 == "--"* ]]; then
        val="${1/--/}"
        declare "$val"="$2"
        shift
    fi
    shift
done

VERSION=$v
ENVIRONMENT=${ENVIRONMENT:-official}
FOLDER=${FOLDER:-public}

if [[  -z $VERSION ]]; 
then
  log_error "Upgrade not started: version number is missing. Add --v followed by the target version number to the upgrade command."
  exit 1
fi

UPGRADE_SCRIPT_PATH="https://zvml-upgrade.s3.amazonaws.com/scripts/$FOLDER/upgrade_to_$VERSION.bash"

if [[ $ENVIRONMENT != qa ]]; then
    UPGRADE_SCRIPT_PATH="https://zertodownloads.s3.amazonaws.com/myz_Zerto/ZVML_Upgarde/official_upgrade_to_$VERSION.bash"
fi
wget --no-check-certificate -O - $UPGRADE_SCRIPT_PATH | bash <(cat) </dev/tty

EOF

chmod 500 /opt/zerto/zlinux/upgrade/upgrade.bash

