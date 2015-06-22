FROM ubuntu:15.04
MAINTAINER Vytautas Astrauskas "vastrauskas@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Install prerequisites.
RUN apt-get update && \
    apt-get install -y software-properties-common unzip wget gdebi-core && \
    apt-get clean

# Install Z3 (v4.4.0)
RUN wget --no-verbose https://launchpad.net/ubuntu/+archive/primary/+files/z3_4.4.0-1_amd64.deb -O /tmp/z3.deb && \
    gdebi -n /tmp/z3.deb && \
    apt-get clean && \
    rm -rf /tmp/*

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
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer libxext-dev libxrender-dev libxtst-dev mercurial && \
    apt-get install -y libgtk2.0-0 libcanberra-gtk-module && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Install SBT
RUN wget --local-encoding=utf-8 --no-verbose 'https://dl.bintray.com/sbt/debian/sbt-0.13.8.deb' -O /tmp/sbt.deb && \
    dpkg -i /tmp/sbt.deb && \
    rm -f /tmp/sbt.deb

# Install IntelliJ IDEA
RUN wget --no-verbose https://download.jetbrains.com/idea/ideaIC-14.1.3.tar.gz -O /tmp/idea.tar.gz && \
    echo 'Installing IntelliJ IDEA' && \
    mkdir -p /tmp/idea && \
    tar -xzf /tmp/idea.tar.gz -C /opt && \
    rm -rf /tmp/*

# Bug work arounds.
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8

ADD run /usr/local/bin/idea

RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get clean && \
    chmod +x /usr/local/bin/idea && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown developer:developer -R /home/developer && \
    chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

USER developer
ENV HOME /home/developer
WORKDIR /home/developer
CMD /usr/local/bin/idea
