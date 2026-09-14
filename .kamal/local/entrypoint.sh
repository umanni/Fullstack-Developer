#!/bin/sh
set -e

install -d -m 700 /root/.ssh
install -m 600 /keys/authorized_keys /root/.ssh/authorized_keys
/usr/sbin/sshd -e

# Unix socket only: skips the TLS cert generation and TCP listener of the default dind setup.
exec dockerd-entrypoint.sh dockerd --host=unix:///var/run/docker.sock
