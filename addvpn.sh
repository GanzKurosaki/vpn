#!/bin/sh
IP=$(wget -qO- ipv4.icanhazip.com);
read -p "Username: " VPN_USER
read -p "Password: " VPN_PASSWORD
read -p "Expired (hari): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
clear

# Add or update VPN user
sed -i "/^\"$VPN_USER\" /d" /etc/ppp/chap-secrets
cat >> /etc/ppp/chap-secrets <<EOF
"$VPN_USER" l2tpd "$VPN_PASSWORD" *
EOF

# shellcheck disable=SC2016
sed -i '/^'"$VPN_USER"':\$1\$/d' /etc/ipsec.d/passwd
VPN_PASSWORD_ENC=$(openssl passwd -1 "$VPN_PASSWORD")
cat >> /etc/ipsec.d/passwd <<EOF
$VPN_USER:$VPN_PASSWORD_ENC:xauth-psk
EOF

# Update file attributes
chmod 600 /etc/ppp/chap-secrets* /etc/ipsec.d/passwd*
echo -e "\n $VPN_USER $exp">>"/root/l2tpakun.conf"
cat <<EOF

================================
IPsec VPN 

Server IP: $IP
IPsec PSK: gcsl2tp
Username: $VPN_USER
Password: $VPN_PASSWORD

By gcsumardani.my.id
=================================
EOF
