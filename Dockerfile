FROM ubuntu:18.04

# Official instructions from
# https://ripple.com/build/rippled-setup/#installation-on-ubuntu-with-alien
RUN apt-get update
RUN apt-get install -y yum-utils alien
RUN rpm -Uvh https://mirrors.ripple.com/ripple-repo-el7.rpm
RUN yumdownloader --enablerepo=ripple-stable --releasever=el7 rippled
RUN rpm --import https://mirrors.ripple.com/rpm/RPM-GPG-KEY-ripple-release && rpm -K rippled*.rpm
RUN alien -i --scripts rippled*.rpm && rm rippled*.rpm

RUN userdel rippled
RUN groupadd --gid 999 rippled \
  && useradd --uid 1000 --gid rippled --shell /bin/bash --create-home rippled

USER rippled

ENTRYPOINT ["/opt/ripple/bin/rippled"]

# P2P && RPC
EXPOSE 51235 5005