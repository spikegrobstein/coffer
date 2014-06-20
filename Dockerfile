FROM ubuntu
MAINTAINER Spike Grobstein <me@spike.cx>

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y git build-essential libboost-all-dev libssl-dev libdb++-dev libminiupnpc-dev autoconf

