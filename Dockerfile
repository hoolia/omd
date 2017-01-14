FROM centos:7
MAINTAINER Samuel Terburg <sterburg@hoolia.eu>
EXPOSE 5000 2222 4730 5666

COPY ansible_omd /root/ansible_omd
ADD  bin/        /usr/local/bin/

ENV OMD_SITE=prod \
    OMD_PROD=/opt/omd/sites/${OMD_SITE} \
    PYTHONPATH=/omd/sites/${OMD_SITE}/lib/python:/omd/sites/${OMD_SITE}/local/lib/python \
    ANSIBLE_CONFIG=/root/ansible_omd/ansible.cfg \
    ANSIBLE_DROPIN_ROLE=dropin_role \
    ANSIBLE_VERBOSITY=debug

RUN rpm -Uvh "http://ftp.uni-stuttgart.de/epel/epel-release-latest-7.noarch.rpm" && \
    yum -y update && \
    yum -y install which lsof vim git openssh-server tree && \
    yum clean all

RUN rpm -Uvh "https://labs.consol.de/repo/testing/rhel7/x86_64/labs-consol-testing.rhel7.noarch.rpm" && \
    yum -y update && \
    yum -y install omd-labs-edition-daily && \
    yum clean all

# -- OMD site creation
RUN sed -i 's|echo "on"$|echo "off"|' /opt/omd/versions/default/lib/omd/hooks/TMPFS && \
    omd create "${OMD_SITE}" && \
    omd config "${OMD_SITE}" set APACHE_TCP_ADDR 0.0.0.0 && \
    omd config "${OMD_SITE}" set APACHE_TCP_PORT 5000 && \
    echo "root"  | passwd --stdin root && \
    echo "admin" | passwd --stdin "${OMD_SITE}" && \
    find / -user prod   -exec chmod a+rwX {} \; && \
    find / -user apache -exec chmod a+rwX {} \;

#USER ${OMD_SITE}
USER 998

WORKDIR ${OMD_PROD}
CMD /usr/local/bin/entrypoint.sh
