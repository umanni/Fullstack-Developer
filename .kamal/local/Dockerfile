# Stand-in for a production host: root SSH access plus its own Docker daemon.
FROM docker:29-dind

# Kamal's local registry reaches this host through an SSH remote port forward,
# which Alpine's sshd disables by default.
RUN apk add --no-cache openssh-server && \
    ssh-keygen -A && \
    sed -i 's/^AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config

COPY --chmod=755 entrypoint.sh /usr/local/bin/server-entrypoint.sh

EXPOSE 22 80
ENTRYPOINT ["server-entrypoint.sh"]
