export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
cat /etc/passwd |sed "s/${OMD_SITE}:x:998:1000/${OMD_SITE}:x:${USER_ID}:${GROUP_ID}/" >${OMD_ROOT}/etc/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=${OMD_ROOT}/etc/passwd
export NSS_WRAPPER_GROUP=/etc/group
