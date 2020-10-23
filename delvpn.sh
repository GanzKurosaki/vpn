#!/bin/sh
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
read -p "Username: " VPN_USER

if printf '%s' "$VPN_USER" | LC_ALL=C grep -q '[^ -~]\+'; then
  exiterr "VPN username must not contain non-ASCII characters."
fi

case "$VPN_USER" in
  *[\\\"\']*)
    exiterr "VPN username must not contain these special characters: \\ \" '"
    ;;
esac

if [ "$(grep -c "^\"$VPN_USER\" " /etc/ppp/chap-secrets)" = "0" ] \
  || [ "$(grep -c "^$VPN_USER:\\\$1\\\$" /etc/ipsec.d/passwd)" = "0" ]; then
cat 1>&2 <<'EOF'
Error: The specified VPN user does not exist in /etc/ppp/chap-secrets
       and/or /etc/ipsec.d/passwd.
EOF
  exit 1
fi

if [ "$(grep -c -v -e '^#' -e '^[[:space:]]*$' /etc/ppp/chap-secrets)" = "1" ] \
  || [ "$(grep -c -v -e '^#' -e '^[[:space:]]*$' /etc/ipsec.d/passwd)" = "1" ]; then
cat 1>&2 <<'EOF'
Error: Cannot delete the only VPN user from /etc/ppp/chap-secrets
       and/or /etc/ipsec.d/passwd.
EOF
  exit 1
fi

clear

cat <<EOF

================================================

VPN user to delete:

Username: $VPN_USER

================================================

EOF


echo "Deleting VPN user..."

# Delete VPN user
sed -i "/^\"$VPN_USER\" /d" /etc/ppp/chap-secrets
# shellcheck disable=SC2016
sed -i '/^'"$VPN_USER"':\$1\$/d' /etc/ipsec.d/passwd
sed -i "/^\"$VPN_USER\" /d" /root/l2tpakun.conf
# Update file attributes
chmod 600 /etc/ppp/chap-secrets* /etc/ipsec.d/passwd*

cat <<'EOF'
Done!

EOF
