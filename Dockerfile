FROM ubuntu:15.04
MAINTAINER Vytautas Astrauskas "vastrauskas@gmail.com"

# Install Z3 (v4.1.1)
RUN apt-get update && \
    apt-get install -y git build-essential autoconf dos2unix g++-4.6 && \
    cd /tmp && \
    git clone https://github.com/Z3Prover/z3.git && \
    cd /tmp/z3 && \
    git checkout z3-4.1.1 && \
    autoconf && \
    CXX=$(which g++-4.6) ./configure && \
    CXX=$(which g++-4.6) make && \
    cp /tmp/z3/bin/external/z3 /usr/bin/z3-4.1.1 && \
    cd / && \
    apt-get clean && \
    rm -rf /tmp/*

# Install Boogie
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list && \
    apt-get update && \
    apt-get install -y mono-complete unzip wget && \
    wget 'https://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=boogie&DownloadId=518016&FileTime=129954091212230000&Build=21018' -O /tmp/boogie.zip && \
    cd /tmp && \
    unzip boogie.zip -d /usr/lib/boogie && \
    echo '#!/bin/bash' > /usr/bin/boogie && \
    echo 'mono --runtime=v4.0.30319 /usr/lib/boogie/Boogie.exe "$@"' >> /usr/bin/boogie && \
    chmod 755 /usr/bin/boogie && \
    apt-get clean && \
    rm -rf /tmp/*

# Fix bug.
RUN cd /usr/lib/boogie && \
    ln -s /usr/bin/z3-4.1.1 z3.exe

# Install Java.
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer libxext-dev libxrender-dev libxtst-dev mercurial && \
    apt-get install -y libgtk2.0-0 libcanberra-gtk-module && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Install Z3 (v4.4.0)
RUN apt-get update && \
    apt-get install -y git build-essential && \
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

RUN apt-get install -y sudo && \
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
