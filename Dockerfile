FROM ubuntu:14.04

MAINTAINER Fadhel Ghorbel


ENV LC_ALL en_US.UTF-8

ENV MNT /mnt
ENV BOSH_AWS_REGION us-east-1
ENV RUBY_VERSION 2.5.1 


COPY terminal_settings.sh $MNT/
ENV TEST ss
COPY fluent-plugin-mysqlslowquerylog $MNT/fluent-plugin-mysqlslowquerylog
#used by on-startup

RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales
RUN apt-get update --fix-missing; apt-get -y upgrade; apt-get clean

# make requests library use the Debian CA bundle (includes Zalando CA)
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt



RUN apt-get install -y xfsprogs \ 
    dialog \
    xinetd \
    debconf-utils \
    toilet figlet \
    git \
    unzip \
    wget \
    curl \
    expect \
    libmysqlclient-dev \
    tree \
    cmake \
    pkg-config \
    build-essential zlibc zlib1g-dev ruby2.0 ruby2.0-dev  openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 \
    python-software-properties \
    language-pack-en \
    vim \
    rsync \
    wget \
    dnsutils \
    libcurl4-openssl-dev \
    make \
    ; \
    apt-get clean
    


RUN  apt-get install -y  libreadline-gplv2-dev \
    tcl-dev \
    tk \
   libncursesw5-dev \
   tk-dev \
   libgdbm-dev \
   libc6-dev \
   libbz2-dev

RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv \
&&  git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
&&  git clone https://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset \
&&  /usr/local/rbenv/plugins/ruby-build/install.sh
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh \
&&  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /root/.bashrc \
&&  echo 'eval "$(rbenv init -)"' >> /root/.bashrc

ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

RUN eval "$(rbenv init -)"; rbenv install 2.5.1 \
&&  eval "$(rbenv init -)"; rbenv global 2.5.1 \
&&  eval "$(rbenv init -)"; gem update --system \
&&  eval "$(rbenv init -)"; gem install bundler -f --no-document


#Install GoLang

#RUN curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz;\
#    tar -xvf go1.6.linux-amd64.tar.gz;\
#    mv go /usr/local;    

#End

# Setup SSH
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo 'root:docker' | chpasswd
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#ENd Setup SSH


RUN   echo "source /mnt/terminal_settings.sh">>  /root/.bashrc;\
    echo "figlet APP__LOGS__FOR " >> /root/.bashrc;
# END aws setup


#Extend ssh session 
RUN echo "    ServerAliveInterval 100" >> /etc/ssh/ssh_config
RUN /etc/init.d/ssh restart

EXPOSE 22



ENV PATH /usr/local/rbenv/bin:$PATH

RUN mkdir -p mkdir -p /etc/fluentd 

ENV MNT /mnt

RUN apt-get install logrotate \
    cron
  

COPY on-startup.sh $MNT/

COPY fluentd.conf  /etc/fluentd/

ENV GOPATH /mnt/go_workspace
ENV PATH $PATH:/usr/local/go/bin

RUN gem install fluentd:0.14.0 --no-ri --no-rdoc \
        oj  \
        json \
    && fluent-gem install fluent-plugin-elasticsearch \
    fluent-plugin-record-modifier fluent-plugin-exclude-filter \
        fluent-plugin-elasticsearch \
        fluent-plugin-record-reformer \
        fluent-plugin-webhdfs \
        fluent-plugin-firehose  \
        fluent-plugin-parser \
        fluent-plugin-rename-key \
        fluent-plugin-record-reformer \
        fluent-plugin-secure-forward \
        fluent-plugin-multi-format-parser \
        fluent-plugin-forest


RUN gem cleanup

EXPOSE 24224

VOLUME ["/mnt/logs", ]

RUN /mnt/on-startup.sh

# Install Supervisor.
RUN apt-get install -y supervisor && \
  rm -rf /var/lib/apt/lists/*  

RUN echo "[supervisord]" > /etc/supervisor/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/supervisord.conf && \
    echo "" >> /etc/supervisor/supervisord.conf && \
    echo "" >> /etc/supervisor/supervisord.conf && \
    echo "[program:fluentd-client]" >> /etc/supervisor/supervisord.conf && \
    echo "command=/usr/local/rbenv/shims/fluentd -c /etc/fluentd/fluentd.conf" >> /etc/supervisor/supervisord.conf && \
    echo "stdout_logfile=/dev/stdout" >> /etc/supervisor/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0 " >> /etc/supervisor/supervisord.conf && \
    echo "" >> /etc/supervisor/supervisord.conf && \
    echo "[program:cron]" >> /etc/supervisor/supervisord.conf && \
    echo "command=/usr/sbin/cron -f" >> /etc/supervisor/supervisord.conf

# Define default command.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]


