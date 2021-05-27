FROM ubuntu:18.04
WORKDIR /root/
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
RUN apt-get install git -y
RUN git clone https://github.com/aws/aws-iot-device-sdk-python.git
RUN adduser --system ggc_user
RUN addgroup --system ggc_group
RUN apt install openjdk-8-jdk -y
WORKDIR /root/aws-iot-device-sdk-python
RUN python setup.py install
WORKDIR /root/
COPY . /root/
RUN ls
#ENTRYPOINT python a.py
ENTRYPOINT cat basicDiscovery.py

