FROM ubuntu:latest


COPY --from=library/docker:latest /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker/compose:latest /usr/local/bin/docker-compose /usr/local/bin/docker-compose
COPY . /app

USER root
RUN apt-get update && apt-get upgrade -y  && apt-get install curl -y && apt-get install -y nmap && apt-get install -y ipcalc
RUN apt-get install -y python3 pip
RUN pip3 install --upgrade --force-reinstall --no-cache-dir docker-compose && ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
RUN python3 -m pip install gvm-tools

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get install -y gvmd && apt-get install -y gvm
RUN apt-get install -y wget && apt-get install -y nano && apt-get install -y cmake && apt-get install -y git
RUN apt-get install -y gcc cmake libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib pkg-config libical-dev xsltproc libgpgme-dev 


ARG USERNAME=user-name-goes-here
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
	&& apt-get update \
	&& apt-get install -y sudo \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

WORKDIR /app

#ENTRYPOINT ["/app/script.sh"]
