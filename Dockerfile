FROM       centos:7
MAINTAINER Samuel Terburg <sterburg@hoolia.eu>
EXPOSE     8080 8443 2222 4730 5666
WORKDIR    ${OMD_ROOT}
ENTRYPOINT /usr/local/bin/entrypoint.sh

COPY ansible_omd /root/ansible_omd
ADD  bin/        /usr/local/bin/

ENV OMD_SITE=default
ENV OMD_ROOT=/opt/omd/sites/${OMD_SITE} \
    PYTHONPATH=/omd/sites/${OMD_SITE}/lib/python:/omd/sites/${OMD_SITE}/local/lib/python \
    ANSIBLE_CONFIG=/root/ansible_omd/ansible.cfg \
    ANSIBLE_DROPIN_ROLE=dropin_role \
    ANSIBLE_VERBOSITY=debug

RUN rpm -Uvh "http://ftp.uni-stuttgart.de/epel/epel-release-latest-7.noarch.rpm" && \
    yum -y update && \
    yum -y install which lsof vim git openssh-server tree && \
    yum clean all

RUN ln -s /opt/rh/httpd24/root/etc/httpd/ /etc/httpd && \
    rpm -Uvh "https://labs.consol.de/repo/testing/rhel7/x86_64/labs-consol-testing.rhel7.noarch.rpm" && \
    yum -y update && \
    yum -y install omd-labs-edition-daily && \
    yum clean all && \
    rm -f /etc/httpd/conf.d/ssl.conf \
          /etc/httpd/conf.d/fcgid.conf \
          /etc/httpd/conf.modules.d/10-fcgid.conf

# -- OMD site creation
RUN sed  -i 's|echo "on"$|echo "off"|' /opt/omd/versions/default/lib/omd/hooks/TMPFS && \
    sed  -i 's|#   Port 22|Port 2222|' /etc/ssh/ssh_config && \
    omd create "${OMD_SITE}" || true && \
    omd config "${OMD_SITE}" set APACHE_TCP_ADDR 0.0.0.0 && \
    omd config "${OMD_SITE}" set APACHE_TCP_PORT 5000 && \
    echo "root"  | passwd --stdin root && \
    echo "admin" | passwd --stdin "${OMD_SITE}" && \
    sed -ri 's/^Listen 80/Listen 0.0.0.0:8080/;             s/^User apache/User default/;             s/^Group apache/Group root/;             s/^(\s*(Error|Custom|Transfer)Log) \S+/\1 |\/usr\/bin\/cat/g;' /etc/httpd/conf/httpd.conf && \
    find / -path /proc -prune -o \( -user ${OMD_SITE} -o -user apache -o -group apache \) -exec chmod a+rwX {} \; || true
#    /usr/local/bin/fix-permissions "${OMD_ROOT}" && \
#    sed -i 's/^Listen 443/Listen 0.0.0.0:8443/' /etc/httpd/conf.d/ssl.conf

#USER ${OMD_SITE}
USER 998
