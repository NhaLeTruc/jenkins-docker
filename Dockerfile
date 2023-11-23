FROM jenkins/jenkins:lts-jdk17

# Install custom plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
# Set executor on leader = 0
#COPY --chown=jenkins:jenkins executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
# Copy files in order to create config-as-code.yaml
COPY modify_casc.py /modify_casc.py
COPY config-as-code.j2 /config-as-code.j2

USER root

# As root:
# - Update all packages
# - Install python3-pip
# - Use pip to install jinja2 dnspython (ignore packages incompatibility)
# - Remove all files and subfiles in /var/lib/apt/lists/
# - Create config-as-code.yaml
# - Grant config-as-code.yaml's access to jenkins user
# - Edit in-place remove window's end of line from modify_casc.py. Note: 's' stands for 'substitue'
# - Edit in-place add a newline then /modify_casc.py after /bin/bash*. Note: 'a' stands for 'insert after'
RUN apt-get update &&\
    apt-get install -y python3-pip &&\
    pip3 install --break-system-packages jinja2 dnspython &&\
    rm -rf /var/lib/apt/lists/* &&\
    touch /config-as-code.yaml &&\
    chown jenkins: /config-as-code.yaml &&\
    sed -i 's/\r//' /modify_casc.py &&\
    sed -i '/\/bin\/bash*/a \\n\/modify_casc.py' /usr/local/bin/jenkins.sh

# User back to jenkins
USER jenkins
