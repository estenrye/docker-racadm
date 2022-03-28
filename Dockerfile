FROM redhat/ubi8

RUN yum -y update && yum install -y wget perl openssl-devel
WORKDIR /opt
RUN wget https://dl.dell.com/FOLDER05920767M/1/DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz
RUN tar -zxvf DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz
WORKDIR /opt/iDRACTools/racadm/
RUN ./install_racadm.sh
ENTRYPOINT ["/opt/dell/srvadmin/bin/idracadm7"]

# Next steps
# - Install Ansible
# - Install stepcli
# - Add playbook for installing letsencrypt certs