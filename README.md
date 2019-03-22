# docker-strongswan
strongSwan in a Docker container

Minimal Docker Run command:

```
docker run --rm -d --privileged -e TZ=YOUR_TZ -e SERVER_DOMAIN=YOUR_DOMAIN -p 500:500/udp -p 4500:4500/udp -v YOUR_FOLDER:/root -v /lib/modules:/lib/modules --name=strongSwan themardy/strongswan:latest
```

Required Variables:

| Variable  | Example |
| ------------- | ------------- |
| TZ  |  Europe/Amsterdam  |
| SERVER_DOMAIN  |  myddns.com |


Optional Variables:

| Variable  | Example |
| ------------- | ------------- |
| LEFTSUBNET  |  0.0.0.0/0,::/0  |
| DNS_SERVERS  |  1.0.0.1,2606:4700:4700::1111 |
| RIGHTSOURCEIP  |  10.10.10.0/24,fd9d:bc11:4020::/48 |

Volumes:

| Volume  | Explaination |
| ------------- | ------------- |
| /lib/modules:/lib/modules  |  strongSwan needs the /lib/modules to run  |
| YOUR_FOLDER:/root  |  Saves the Certificate files |

Ports: 

| Port  | Explaination |
| ------------- | ------------- |
| 500:500/udp  |  Needed by strongSwan  |
| 4500:4500/udp  |  Needed by strongSwan |