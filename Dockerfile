FROM mongo

RUN apt-get update
RUN apt-get install -y python-pip
RUN pip install awscli
RUN apt-get install -y vim
RUN mkdir -p /backup/data
RUN apt-get install -y dnsutils

ADD run /backup/run
WORKDIR /backup


