#! /bin/bash
sudo ulimit -n 65535

sudo yum update
sudo yum install -y docker git wget
sudo systemctl start docker

sudo docker run \
--rm \
--detach \
--name=protonvpn \
--device=/dev/net/tun \
--cap-add=NET_ADMIN \
--env PROTONVPN_USERNAME=${proton_user} \
--env PROTONVPN_PASSWORD=${proton_password} \
--env PROTONVPN_TIER=2 \
--env PROTONVPN_SERVER=RANDOM \
ghcr.io/tprasadtp/protonvpn:latest

mkdir dis; cd dis
latest=$(curl --silent "https://api.github.com/repos/disbalancer-project/main/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
wget https://github.com/disbalancer-project/main/releases/download/$latest/disbalancer-go-client-linux-amd64

cat << EOF > Dockerfile
FROM alpine
COPY . /app/

RUN chmod +x /app/disbalancer-go-client-linux-amd64
RUN apk update
RUN apk add curl netcat-openbsd

ENTRYPOINT ["/app/disbalancer-go-client-linux-amd64"]
EOF

sudo docker build -t dis .

sudo docker run \
--detach \
--restart always \
--net=container:protonvpn \
dis:latest
