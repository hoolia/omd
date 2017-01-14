export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
cat /etc/passwd |sed "s/prod:x:998:1000/prod:x:${USER_ID}:${GROUP_ID}/" >${OMD_PROD}/etc/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=${OMD_PROD}/etc/passwd
export NSS_WRAPPER_GROUP=/etc/group
