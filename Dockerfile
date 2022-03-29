FROM tgagor/centos:stream8

ENV VAULT_AUTH_METHOD="--vault-password-file=/secrets/secret.key" \
  VAULT_FILE="/secrets/creds.yml" \
  ANSIBLE_CONFIG=/ansible/ansible.cfg \
  INVENTORY_FILE=/ansible/inventory.yml \
  KUBECONFIG=/home/automation-user/.kube/config \
  PYENV_VIRTUALENV_DISABLE_PROMPT=1

# git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
RUN yum -y update \
  && yum install -y epel-release \
  && yum install -y \
      bzip2-devel \
      curl \
      git \
      gcc \
      libffi-devel \
      openssl-devel \
      openssh-clients \
      perl \
      python3 \
      python3-pip \
      readline-devel \
      sudo \
      sqlite-devel \
      zlib-devel \
  && adduser automation-user \
  && usermod -aG wheel automation-user \
  && echo 'automation-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER automation-user
COPY --chown=automation-user .bashrc /home/automation-user/.
RUN git clone https://github.com/pyenv/pyenv.git /home/automation-user/.pyenv \
  && git clone https://github.com/yyuu/pyenv-virtualenv.git /home/automation-user/.pyenv/plugins/pyenv-virtualenv \
  && source /home/automation-user/.bashrc \
  && pyenv install 3.10.4

WORKDIR /home/automation-user

COPY prereq.requirements.txt requirements.txt /tmp/src/

RUN source /home/automation-user/.bashrc \
  && pyenv local 3.10.4 \
  && pyenv virtualenv 3.10.4 py3.10.4 \
  && pyenv activate py3.10.4 \
  && pyenv local py3.10.4 \
  # && pyenv exec python -m pip install --upgrade pip \
  # && pyenv exec python -m pip install --force setuptools setuptools-git \
  && pyenv exec python -m pip install --force -r /tmp/src/prereq.requirements.txt \
  && pyenv exec python -m pip install -r /tmp/src/requirements.txt

COPY configure.yaml /tmp/src/
RUN source /home/automation-user/.bashrc \
  && pyenv exec ansible-playbook -i localhost, /tmp/src/configure.yaml

ENTRYPOINT ["/opt/dell/srvadmin/bin/idracadm7"]
