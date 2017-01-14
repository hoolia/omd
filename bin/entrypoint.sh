#!/bin/bash

source /usr/local/bin/generate_container_user

# Check if dropin role is defined
if [ `ls -1 ${OMD_PROD}/ansible/dropin_role/ 2>/dev/null | wc -l` -gt 0 ]; then
  echo "Executing Ansible drop-in role..."
  ${OMD_PROD}/bin/ansible-playbook -i localhost, ${OMD_PROD}/ansible/playbook.yml -c local -e ANSIBLE_DROPIN_ROLE=$ANSIBLE_DROPIN_ROLE $ANSIBLE_VERBOSITY
else
  echo "No Ansible drop-in role defined, nothing to do."
fi

echo "Starting site..."
echo "----------------------"
omd start ${OMD_SITE}
echo "----------------------"


echo "Starting Apache web server..."
exec /usr/sbin/httpd -D FOREGROUND
