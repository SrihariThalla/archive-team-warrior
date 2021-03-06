# Build

FROM debian:buster-20210111-slim AS build

RUN apt update
RUN apt upgrade -y
RUN apt install -y --no-install-recommends \
        autoconf automake autopoint gettext texinfo gperf flex gcc git make net-tools \
        libidn2-0 libc6 libpsl-dev libpcre3-dev pkg-config libssl-dev zlib1g-dev liblzma-dev liblz4-dev \
        libgnutls28-dev liblua5.1-0 liblua5.1-0-dev  pciutils sudo wget curl \
        python3 python3-pip python3-setuptools rsync software-properties-common
#RUN apt-get install -y libc-ares-dev
#libmetalink libcares

WORKDIR /app
RUN git clone --depth 1 https://github.com/facebook/zstd.git
WORKDIR /app/zstd
RUN make install

WORKDIR /app
RUN git clone --depth 1 --recurse-submodules https://github.com/ArchiveTeam/wget-lua.git
WORKDIR /app/wget-lua
RUN ./bootstrap
RUN ./configure --with-ssl=openssl
RUN make


# Production

FROM python:3.9.1-slim-buster

RUN apt update
RUN apt upgrade -y
RUN apt install -y git liblua5.1-0 rsync luarocks

RUN pip3 install requests warcio zstandard
RUN pip3 install -e git+https://github.com/SrihariThalla/seesaw-kit.git@09591e7ddea637d460dee1841bf609f9a2181ba4#egg=seesaw

WORKDIR /app

RUN mkdir data
RUN mkdir projects

RUN git clone --depth 1 --recurse-submodules https://github.com/ArchiveTeam/warrior-code2.git

COPY --from=build /app/wget-lua/src/wget /usr/local/bin/wget-at
COPY start.py .

EXPOSE 8001

CMD [ "python", "start.py" ]
