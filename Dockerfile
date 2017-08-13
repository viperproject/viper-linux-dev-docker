FROM ubuntu:16.04
MAINTAINER Viper Team "viper@inf.ethz.ch"

ENV DEBIAN_FRONTEND noninteractive

# Install prerequisites.
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y software-properties-common unzip wget curl gdebi-core locales python-dev python3-dev && \
    apt-get clean

# Install Z3 (post v4.5.0).
RUN apt-get update && \
    apt-get install -y git build-essential python && \
    cd /tmp && \
    git clone https://github.com/Z3Prover/z3.git && \
    cd /tmp/z3 && \
    git checkout 3865c453827506fc5c9d6c6c7c3d66d17030f158 && \
    ./configure && \
    cd build && \
    make && \
    make install && \
    apt-get clean && \
    rm -rf /tmp/z3

# Install Mono.
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list && \
    apt-get update && \
    apt-get install -y mono-complete tzdata && \
    apt-get clean

# Install Boogie.
RUN wget --no-verbose 'https://github.com/boogie-org/boogie/archive/f085c05a5c49c730ca28be74b79d080f05f0b72e.zip' -O /tmp/boogie.zip && \
    cd /tmp && \
    unzip -q boogie.zip && \
    cd boogie-* && \
    wget --no-verbose https://nuget.org/nuget.exe && \
    xbuild Source/Boogie.sln && \
    mkdir -p /usr/lib/boogie/ && \
    cp -r Binaries/* /usr/lib/boogie/ && \
    echo '#!/bin/bash' > /usr/bin/boogie && \
    echo 'mono --runtime=v4.0.30319 /usr/lib/boogie/Boogie.exe "$@"' >> /usr/bin/boogie && \
    chmod 755 /usr/bin/boogie && \
    cd /usr/lib/boogie && \
    ln -s /usr/bin/z3 z3.exe && \
    apt-get clean && \
    rm -rf /tmp/*

# Install Java.
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk ca-certificates-java && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java && \
    apt-get clean && \
    rm -rf /tmp/*

# Install SBT.
RUN apt-get update && \
    apt-get install apt-transport-https && \
    echo "deb https://dl.bintray.com/sbt/debian /" >> /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    apt-get update && \
    apt-get install sbt && \
    apt-get clean

# Install Nailgun.
RUN apt-get update && \
    apt-get install -y nailgun && \
    apt-get clean

# Install Viper-Runner dependencies.
RUN apt-get update && \
    apt-get install -y python3-psutil python3-pip && \
    apt-get clean && \
    pip3 install --upgrade pip && \
    pip3 install pyhocon

# Install sudo, shell, etc.
RUN apt-get update && \
    apt-get install -y sudo fish man-db mercurial && \
    apt-get clean

# Install IntelliJ IDEA.
RUN wget --no-verbose https://download.jetbrains.com/idea/ideaIC-2017.2.tar.gz -O /tmp/idea.tar.gz && \
    echo 'Installing IntelliJ IDEA' && \
    mkdir -p /tmp/idea && \
    tar -xzf /tmp/idea.tar.gz -C /opt && \
    rm -rf /tmp/*

# Bug work arounds.
RUN locale-gen en_US.UTF-8
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ADD run /usr/local/bin/idea

# Install SSH server.
RUN apt-get update && \
    apt-get install -y openssh-server && \
    apt-get clean && \
    echo 'AddressFamily inet' >> /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
EXPOSE 22

ADD initialize /usr/local/bin/initialize

RUN chmod +x /usr/local/bin/initialize && \
    chmod +x /usr/local/bin/idea

CMD /usr/local/bin/initialize
