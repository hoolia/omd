#!/bin/bash

source /usr/local/bin/generate_container_user.sh

# Check if dropin role is defined
if [ `ls -1 ${OMD_ROOT}/ansible/dropin_role/ 2>/dev/null | wc -l` -gt 0 ]; then
  echo "Executing Ansible drop-in role..."
  ${OMD_ROOT}/bin/ansible-playbook -i localhost, ${OMD_ROOT}/ansible/playbook.yml -c local -e ANSIBLE_DROPIN_ROLE=$ANSIBLE_DROPIN_ROLE $ANSIBLE_VERBOSITY
else
  echo "No Ansible drop-in role defined, nothing to do."
fi

echo "Starting site..."
echo "----------------------"
service omd start
echo "----------------------"


echo "Starting Apache reverse proxy..."
exec httpd -D FOREGROUND
