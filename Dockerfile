FROM java:8-jdk

ENV JENKINS_VERSION 2.19.2
ENV JENKINS_SHA 32b8bd1a86d6d4a91889bd38fb665db4090db081
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV JENKINS_UC https://updates.jenkins-ci.org

ENV TINI_SHA 066ad710107dc7ee05d3aa6e4974f01dc98f3888

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

ENV TZ=Europe/Berlin

RUN apt-get update && \
    apt-get install -y wget git curl zip ruby cron sudo qemu-kvm cpu-checker file && \
    apt-get autoremove --purge && apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

RUN /usr/bin/gem install bundler

RUN echo $TZ | sudo tee /etc/timezone
RUN sudo dpkg-reconfigure --frontend noninteractive tzdata

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins

RUN addgroup kvm
RUN usermod -a -G kvm jenkins
RUN chgrp kvm /dev/kvm
COPY 60-qemu-kvm.rules /etc/udev/rules.d/60-qemu-kvm.rules

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME /var/jenkins_home

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

# Use tini as subreaper in Docker container to adopt zombie processes
RUN curl -fL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini && \
    echo "$TINI_SHA /bin/tini" | sha1sum -c -

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# could use ADD but this one does not check Last-Modified header
# see https://github.com/docker/docker/issues/8331
RUN curl -fL http://mirrors.jenkins-ci.org/war-stable/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war && \
    echo "$JENKINS_SHA /usr/share/jenkins/jenkins.war" | sha1sum -c -

RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

USER jenkins

COPY jenkins.sh /usr/local/bin/jenkins.sh

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
