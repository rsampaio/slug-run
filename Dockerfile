FROM ubuntu:trusty

RUN apt-get update && \ 
    apt-get install -y curl jq libxslt1.1 libxml2 postgresql-client libpq5 && \
    curl https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz | tar zxf - -C /usr/bin && \
    apt-get clean all

COPY slug-run.sh /usr/bin/slug-run.sh

CMD ["/usr/bin/slug-run.sh"]
