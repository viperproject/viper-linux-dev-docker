FROM ubuntu:14.04
MAINTAINER Vytautas Astrauskas "vastrauskas@gmail.com"

# Install Java.
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer libxext-dev libxrender-dev libxtst-dev mercurial && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Install libgtk as a separate step so that we can share the layer above with
# the netbeans image
RUN apt-get update && apt-get install -y libgtk2.0-0 libcanberra-gtk-module

# Install Git
RUN apt-get update && \
    apt-get install -y git libcurl4-openssl-dev build-essential autoconf zlib1g-dev gettext && \
    cd /tmp && \
    git clone https://github.com/git/git.git && \
    cd /tmp/git && \
    make configure && \
    ./configure --prefix=/usr && \
    make all && \
    make install && \
    apt-get clean && \
    rm -rf /tmp/*

# Install Z3 (v4.3.2)
RUN apt-get update && \
    apt-get install -y build-essential unzip && \
    cd /tmp && \
    git clone https://git01.codeplex.com/z3 && \
    cd /tmp/z3 && \
    git checkout v4.3.2 && \
    python scripts/mk_make.py && \
    cd build && \
    make && \
    make install && \
    rm -rf /tmp/z3

# Install SBT
RUN wget https://dl.bintray.com/sbt/debian/sbt-0.13.7.deb -O /tmp/sbt.deb && \
    dpkg -i /tmp/sbt.deb && \
    rm -f /tmp/sbt.deb

# Install IntelliJ IDEA
RUN wget https://download.jetbrains.com/idea/ideaIC-14.0.3.tar.gz -O /tmp/idea.tar.gz && \
    echo 'Installing IntelliJ IDEA' && \
    mkdir -p /tmp/idea && \
    tar -xzf /tmp/idea.tar.gz -C /opt && \
    cd /tmp && \
    wget -c 'http://plugins.jetbrains.com/plugin/download?pr=idea_ce&updateId=18845' -O /tmp/scala.zip && \
    unzip scala.zip && \
    mkdir -p /home/developer/.IdeaIC14/config/plugins && \
    mv /tmp/Scala /home/developer/.IdeaIC14/config/plugins && \
    rm -rf /tmp/*

# Bug work arounds.
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8

ADD run /usr/local/bin/idea

RUN chmod +x /usr/local/bin/idea && \
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
