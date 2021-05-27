FROM ubuntu:18.04
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
WORKDIR /root/
COPY .  /root/
ENTRYPOINT python basic.py
