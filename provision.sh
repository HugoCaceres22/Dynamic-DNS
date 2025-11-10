#!/bin/bash

apt update -y
apt install -y isc-dhcp-server bind9

cat > /etc/dhcp/dhcpd.conf <<EOF
subnet 192.168.56.0 netmask 255.255.255.0 {
  range 192.168.56.20 192.168.56.30;
  option routers 192.168.56.10;
  option domain-name-servers 192.168.56.10;
}
EOF

echo 'INTERFACESv4="eth1"' > /etc/default/isc-dhcp-server

cat > /etc/bind/named.conf.local <<EOF
zone "hugocm.local" {
  type master;
  file "/var/lib/bind/db.hugocm.local";
};
EOF

cp /etc/bind/db.local /var/lib/bind/db.hugocm.local
sed -i 's/localhost./srv.hugocm.local./g' /var/lib/bind/db.hugocm.local
sed -i 's/127.0.0.1/192.168.56.10/g' /var/lib/bind/db.hugocm.local

systemctl restart isc-dhcp-server
systemctl restart bind9
