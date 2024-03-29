ARG  ALPINE_VERSION="${ALPINE_VERSION:-3.10}"
FROM alpine:"${ALPINE_VERSION}"

# Set the lang, you can also specify it as as environment variable through docker-compose.yml
ENV TZ="Asia/Shanghai" \
    USER_LOGIN_SHELL="/bin/bash" \
    USER_LOGIN_SHELL_FALLBACK="/bin/ash"

# Iterate through all locale and install it
# Note that locale -a is not available in alpine linux, use `/usr/glibc-compat/bin/locale -a` instead
COPY locale.md /locale.md
COPY entrypoint.sh /opt/entrypoint.sh

RUN apk update && apk add --no-cache ca-certificates bash openssh tzdata rsync && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa && \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin\ yes/" /etc/ssh/sshd_config && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-bin-2.30-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-i18n-2.30-r0.apk && \
    apk add glibc-2.30-r0.apk glibc-bin-2.30-r0.apk glibc-i18n-2.30-r0.apk && \
    chmod 755 /opt/entrypoint.sh && \
    chmod 4755 /bin/busybox && \
    rm -rf /var/cache/apk/* && \
    rm -rf /glibc-* && \
    rm -rf /tmp/*

RUN cat /locale.md | xargs -i /usr/glibc-compat/bin/localedef -i {} -f UTF-8 {}.UTF-8

EXPOSE 22

ENTRYPOINT ["/opt/entrypoint.sh"]
