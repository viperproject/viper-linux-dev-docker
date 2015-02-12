FROM ubuntu:14.04
MAINTAINER Vytautas Astrauskas "vastrauskas@gmail.com"

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer libxext-dev libxrender-dev libxtst-dev mercurial && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8

# Install libgtk as a separate step so that we can share the layer above with
# the netbeans image
RUN apt-get update && apt-get install -y libgtk2.0-0 libcanberra-gtk-module

# Install Z3
RUN wget 'https://download-codeplex.sec.s-msft.com/Download/SourceControlFileDownload.ashx?ProjectName=z3&changeSetId=cee7dd39444c9060186df79c2a2c7f8845de415b' -O /tmp/z3.zip && \
    echo 'Installing Z3' && \
    apt-get install -y unzip python build-essential && \
    unzip /tmp/z3.zip -d /tmp/z3 && \
    cd /tmp/z3/ && \
    python scripts/mk_make.py && \
    cd build && \
    make && \
    make install && \
    rm -rf /tmp/z3.zip /tmp/z3

# Install SBT
RUN wget https://dl.bintray.com/sbt/debian/sbt-0.13.7.deb -O /tmp/sbt.deb && \
    dpkg -i /tmp/sbt.deb && \
    rm -f /tmp/sbt.deb

# Install IntelliJ IDEA
RUN wget https://download.jetbrains.com/idea/ideaIC-14.0.3.tar.gz -O /tmp/idea.tar.gz && \
    echo 'Installing IntelliJ IDEA' && \
    mkdir -p /tmp/idea && \
    tar -xzf /tmp/idea.tar.gz -C /opt && \
    rm -rf /tmp/*

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
