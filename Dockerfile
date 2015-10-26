FROM ubuntu:15.04
MAINTAINER Vytautas Astrauskas "vastrauskas@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Install prerequisites.
RUN apt-get update && \
    apt-get install -y software-properties-common unzip wget gdebi-core && \
    apt-get clean

# Install Z3 (v4.4.0)
RUN apt-get update && \
    apt-get install -y git build-essential python && \
    cd /tmp && \
    git clone https://github.com/Z3Prover/z3.git && \
    cd /tmp/z3 && \
    git checkout z3-4.4.0 && \
    python scripts/mk_make.py && \
    cd build && \
    make && \
    make install && \
    apt-get clean && \
    rm -rf /tmp/z3

# Install Boogie
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list && \
    apt-get update && \
    apt-get install -y mono-complete && \
    wget 'https://github.com/boogie-org/boogie/archive/56916c9d12f608dc580f4da03ef3dcbe35f42ef8.zip' -O /tmp/boogie.zip && \
    cd /tmp && \
    unzip boogie.zip && \
    cd boogie-* && \
    wget https://nuget.org/nuget.exe && \
    mono ./nuget.exe restore Source/Boogie.sln && \
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
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev mercurial && \
    apt-get install -y libgtk2.0-0 libcanberra-gtk-module && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Install SBT
RUN wget --local-encoding=utf-8 --no-verbose 'https://dl.bintray.com/sbt/debian/sbt-0.13.8.deb' -O /tmp/sbt.deb && \
    dpkg -i /tmp/sbt.deb && \
    rm -f /tmp/sbt.deb

# Install Nailgun.
RUN apt-get update && \
    apt-get install -y nailgun && \
    apt-get clean

# Install IntelliJ IDEA
RUN wget --no-verbose https://download.jetbrains.com/idea/ideaIC-14.1.5.tar.gz -O /tmp/idea.tar.gz && \
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

RUN apt-get update && \
    apt-get install -y sudo fish man-db && \
    apt-get clean && \
    chmod +x /usr/local/bin/idea && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/usr/bin/fish" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown developer:developer -R /home/developer && \
    chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

USER developer
ENV HOME /home/developer
WORKDIR /home/developer
CMD /usr/bin/fish
