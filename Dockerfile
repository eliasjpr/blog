FROM crystallang/crystal

RUN apt-get update && \
    apt-get install -y build-essential curl libevent-dev libssl-dev libxml2-dev libyaml-dev libgmp-dev git && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl http://crystal-lang.s3.amazonaws.com/llvm/llvm-3.5.0-1-linux-x86_64.tar.gz | tar xz -C /opt

ADD . /opt/crystal-head

WORKDIR /opt/crystal-head
ENV CRYSTAL_CONFIG_VERSION HEAD
ENV CRYSTAL_CONFIG_PATH lib:/opt/crystal-head/src:/opt/crystal-head/libs
ENV LIBRARY_PATH /opt/crystal/embedded/lib
ENV PATH /opt/crystal-head/bin:/opt/llvm-3.5.0-1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

MAINTAINER Elias J. Perez "eliasjpr@gmail.com"

ENV AMBER_VERSION=v0.1.13
ENV AMBER_ENV=production
ENV PORT=80

RUN crystal --version

ADD ./ /opt/blog-app/
WORKDIR /opt/blog-app

EXPOSE 80

RUN crystal deps
RUN crystal build --release ./src/blog.cr -o ./app
RUN export PROCESS_COUNT=$(nproc) & PORT=$PORT & AMBER_ENV=$AMBER_ENV && ./app

CMD ["crystal", "spec"]
