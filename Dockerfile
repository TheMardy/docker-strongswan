FROM alpine:3.8

# Install Strongswan

RUN apk add --update-cache --upgrade \
    strongswan \
    iptables \ 
    bash \
    gettext \ 
    && rm -rf /var/cache/apk/*  

# Add init script and config files

ADD ./scripts/* /usr/bin/
RUN mkdir /usr/config_files
ADD ./etc/* /usr/config_files/
RUN chmod +x /usr/bin/init.sh && chmod +x /usr/bin/adduser

VOLUME /root/
VOLUME /lib/modules

EXPOSE 500/udp 4500/udp

CMD /usr/bin/init.sh
