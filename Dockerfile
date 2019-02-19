FROM phusion/baseimage
MAINTAINER David Parrish <david@dparrish.com>

EXPOSE 80 8888
VOLUME /certs
WORKDIR /certs
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get -y install wget git nginx && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Go
RUN cd /usr/local && wget -q https://dl.google.com/go/go1.11.linux-amd64.tar.gz && tar zxf go1.11.linux-amd64.tar.gz && rm go1.11.linux-amd64.tar.gz
ENV GOROOT=/usr/local/go
ENV GOPATH=/root/go
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Install cfssl
RUN apt-get update && apt-get -y install build-essential && go get -u github.com/cloudflare/cfssl/cmd/... && apt-get -y purge build-essential && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD create_*.sh shred_root.sh set_base_url.sh crl.sh /usr/local/bin/
ADD *.json /install/
ADD serve.sh /etc/service/cfssl/run
ADD ocsp.sh /etc/service/ocsp/run
ADD nginx.conf /etc/nginx/sites-available/default
ADD nginx.sh /etc/service/nginx/run
ADD crontab /etc/cron.d/crl.sh
