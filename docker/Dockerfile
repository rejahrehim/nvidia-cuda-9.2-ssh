FROM nvidia/cuda:9.2-base-ubuntu16.04


RUN apt update

RUN apt install -y ssh

COPY ssh_config /etc/ssh/ssh_config
COPY sshd_config /etc/ssh/sshd_config
COPY motd /etc/motd

COPY user.sh /usr/local/bin/user.sh
RUN chmod +x /usr/local/bin/user.sh
RUN /usr/local/bin/user.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD tail -f /dev/null
