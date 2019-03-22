#!/bin/bash
set -e

if [ ! -f /root/ca/certs/fullchain.pem ]
then
# Creating Certificate Authority

    mkdir -p ~/ca/cacerts && mkdir -p ~/ca/certs && mkdir -p ~/ca/private && chmod 700 ~/ca

    ipsec pki --gen --type rsa --size 4096 --outform pem > ~/ca/private/ca-privkey.pem

    ipsec pki --self --ca --lifetime 3650 --in ~/ca/private/ca-privkey.pem \
       --type rsa --dn "C=${TZ}, O=IKEv2 VPN Server, CN=VPN Root CA" --outform pem > ~/ca/cacerts/ca-chain.pem

# Generate Certificate for VPN server

    ipsec pki --gen --type rsa --size 4096 --outform pem > ~/ca/private/privkey.pem

    ipsec pki --pub --in ~/ca/private/privkey.pem --type rsa \
      | ipsec pki --issue --lifetime 1825 \
         --cacert ~/ca/cacerts/ca-chain.pem \
         --cakey ~/ca/private/ca-privkey.pem \
         --dn "C=${TZ}, O=IKEv2 VPN SERVER, CN=${SERVER_DOMAIN}" --san "${SERVER_DOMAIN}" \
         --flag serverAuth --flag ikeIntermediate --outform pem \
      >  ~/ca/certs/fullchain.pem


    echo "________________Certificate_Below_This_Line_________________"
    cat /etc/ipsec.d/cacerts/ca-chain.pem
    echo "---------------Certificate_Above_This_Line__________________"

else
echo "*** Certificates already created. Not creating new ones. ***"
fi

# Copy the certs & configs into the right folder
cp -r ~/ca/* /etc/ipsec.d/
cp -r ~/etc/* /etc/

# Checking variables, setting default if empty.

if [ -z "$DNS_SERVERS" ]; then
  export DNS_SERVERS='1.1.1.1,1.0.0.1,2606:4700:4700::1111,2606:4700:4700::1001'
fi

if [ -z "$LEFTSUBNET" ]; then
  export LEFTSUBNET="0.0.0.0/0,::/0"
fi

if [ -z "$RIGHTSOURCEIP" ]; then
  export RIGHTSOURCEIP="10.10.10.0/24,fd9d:bc11:4020::/48"
fi

# Filling config files
envsubst '
          ${TZ}
          ${DNS_SERVERS}
          ${LEFTSUBNET}
          ${RIGHTSOURCEIP}
          ${SERVER_DOMAIN}
         ' < /etc/ipsec.conf > /etc/ipsec.conf

# sysctl rules
sysctl net.ipv4.ip_forward=1
sysctl net.ipv4.conf.all.accept_redirects=0
sysctl net.ipv4.conf.all.send_redirects=0
sysctl net.ipv4.ip_no_pmtu_disc=1

# iptables
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o eth0 -m policy --pol ipsec --dir out -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE

# Remove starter process if already running
rm -f /var/run/starter.charon.pid

# Start the server
/usr/sbin/ipsec start --nofork

