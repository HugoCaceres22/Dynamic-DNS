# Práctica: Configuración de DHCP y DNS Dinámico

Este proyecto forma parte del módulo de **Planificación y Administración de Redes**, y tiene como objetivo **configurar un servidor DHCP y DNS con actualización dinámica** en un entorno Linux.

---

## Objetivos de la práctica

- Instalar y configurar los servicios **DHCP** y **DNS (BIND9)**.
- Permitir que las máquinas cliente obtengan **direcciones IP dinámicas**.
- Hacer que el **servidor DNS actualice automáticamente** sus registros cuando el servidor DHCP asigne nuevas IPs.
- Verificar el correcto funcionamiento de la resolución **directa** e **inversa**.

---

## Componentes del entorno

| Rol | Descripción | IP |
|------|--------------|----|
| Servidor | Debian/Ubuntu con servicios DHCP y DNS instalados | 192.168.1.1 |
| Cliente | Máquina Linux o Windows con IP dinámica | Automática (DHCP) |

# **DHCP DNS Inglés**

## **Initial server checks:**

Test isc-dhcp-server

vagrant@servidor:~$ systemctl status isc-dhcp-server 
● isc-dhcp-server.service - LSB: DHCP server 
     Loaded: loaded (/etc/init.d/isc-dhcp-server; generated) 
     Active: active (running) since Thu 2025-11-13 10:02:33 UTC; 1min 34s ago 
       Docs: man:systemd-sysv-generator(8) 
    Process: 3882 ExecStart=/etc/init.d/isc-dhcp-server start (code=exited, 
status=0/SUCCESS) 
      Tasks: 4 (limit: 510) 
     Memory: 6.6M 
        CPU: 25ms 
     CGroup: /system.slice/isc-dhcp-server.service 
             └─3897 /usr/sbin/dhcpd -4 -q -cf /etc/dhcp/dhcpd.conf eth1 

Test bind9 

vagrant@servidor:~$ systemctl status bind9 
● named.service - BIND Domain Name Server 
     Loaded: loaded (/lib/systemd/system/named.service; enabled; vendor preset: enabled) 
     Active: active (running) since Thu 2025-11-13 10:02:33 UTC; 1min 39s ago 
       Docs: man:named(8) 
   Main PID: 3938 (named) 
      Tasks: 10 (limit: 510) 
     Memory: 10.5M 
        CPU: 69ms 
     CGroup: /system.slice/named.service 
             └─3938 /usr/sbin/named -f -u bind 

---

## **Initial customer checks:**

Receive an IP address from the server that is within the specified range:

vagrant@cliente:~$ ip a 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group 
default qlen 1000 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 
    inet 127.0.0.1/8 scope host lo 
       valid_lft forever preferred_lft forever 
    inet6 ::1/128 scope host  
       valid_lft forever preferred_lft forever 
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP 
group default qlen 1000 
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff 
    altname enp0s3 
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0 
       valid_lft 86376sec preferred_lft 86376sec 
    inet6 fd17:625c:f037:2:a00:27ff:fe8d:c04d/64 scope global dynamic mngtmpaddr  
       valid_lft 86376sec preferred_lft 14376sec 
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link  
       valid_lft forever preferred_lft forever 
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP 
group default qlen 1000 
    link/ether 08:00:27:2a:44:a7 brd ff:ff:ff:ff:ff:ff 
    altname enp0s8 
    inet 192.168.56.20/24 brd 192.168.56.255 scope global dynamic eth1 
       valid_lft 43180sec preferred_lft 43180sec 
    inet6 fe80::a00:27ff:fe2a:44a7/64 scope link  
       valid_lft forever preferred_lft forever 

---

## **DNS Check**

vagrant@cliente:~$ cat /etc/resolv.conf  
nameserver 192.168.56.10

con el dig:

vagrant@cliente:~$ dig servidor.hugocm.local

; <<>> DiG 9.16.50-Debian <<>> servidor.hugocm.local  
;; global options: +cmd  
;; Got answer:  
;; WARNING: .local is reserved for Multicast DNS  
;; You are currently testing what happens when an mDNS query is leaked to DNS  
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 1195  
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1  

;; OPT PSEUDOSECTION:  
; EDNS: version: 0, flags:; udp: 1232  
; COOKIE: 63113811b7270608010000006915bfc2b17b25fcd2208e8c (good)  
;; QUESTION SECTION:  
;servidor.hugocm.local. IN A  

;; ANSWER SECTION:  
servidor.hugocm.local. 604800 IN A 192.168.56.10  

---

## **2.1. Generar la Clave de Seguridad (en el servidor DNS)**

On the server machine:

If I put the PDF command I receive this error:

vagrant@servidor:~$ sudo tsig-keygen -a hmac-sha256 ddns-key > /etc/bind/ddns.key  
-bash: /etc/bind/ddns.key: Permission denied  

So to solve it I use this other that writes with sudo:

vagrant@servidor:~$ sudo tsig-keygen -a hmac-sha256 ddns-key | sudo tee /etc/bind/ddns.key  
key "ddns-key" {  
        algorithm hmac-sha256;  
        secret "mCdFSIjwQC2bH3AGd8AReei+2GXFlkkfANoRyHQ3XbY=";  
};  

**hacer que BIND9 cargue la clave TSIG al arrancar**

I modified the file with sudo nano /etc/bind/named.conf.local , there I add these 2 lines:

include "/etc/bind/ddns.key";  
allow-update { key ddns-key; }

Must be like this:

include "/etc/bind/ddns.key";

zone "hugocm.local" {  
  type master;  
  file "/var/lib/bind/db.hugocm.local";  
  allow-update { key ddns-key; };  
};  

Now i add this on the file with: sudo nano /etc/dhcp/dhcpd.conf

include "/etc/bind/ddns.key"

The DDNS configuration

ddns-update-style interim;  
ddns-updates on;  
ddns-domainname "hugocm.local";  
ddns-rev-domainname "in-addr.arpa.";  
update-static-leases on;  

zone hugocm.local. {  
    primary 192.168.56.10;  
    key ddns-key;  
}  

At the end must be like this:

include "/etc/bind/ddns.key";  

ddns-update-style interim;  
ddns-updates on;  
ddns-domainname "hugocm.local";  
ddns-rev-domainname "in-addr.arpa.";  
update-static-leases on;  

subnet 192.168.56.0 netmask 255.255.255.0 {  
  range 192.168.56.20 192.168.56.30;  
  option routers 192.168.56.10;  
  option domain-name-servers 192.168.56.10;  
}  

zone hugocm.local. {  
    primary 192.168.56.10;  
    key ddns-key;  
}  

---

## **Tests (Client renew + DNS update)**

vagrant@cliente:~$ sudo dhclient -r eth1  
vagrant@cliente:~$ sudo dhclient eth1  

Then check on server:

vagrant@servidor:~$ sudo cat /var/lib/bind/db.hugocm.local  
$ORIGIN .  
$TTL 604800 ; 1 week  
hugocm.local IN SOA servidor.hugocm.local. root.hugocm.local. (  
2 ; serial  
604800 ; refresh  
86400 ; retry  
2419200 ; expire  
604800 ; minimum  
)  
NS servidor.hugocm.local.  
$ORIGIN hugocm.local.  
$TTL 3600 ; 1 hour  
cliente A 192.168.56.22  
TXT "008652e7829f265ce51c1f589fb65aeb3d"  
servidor A 192.168.56.10  

---

## **Reverse zone**

56.168.192.in-addr.arpa

File created at:

/var/cache/bind/db.56.168.192.in-addr.arpa

Content:

$TTL 604800  
@ IN SOA servidor.hugocm.local. root.hugocm.local. (  
1  
604800  
86400  
2419200  
604800 )  
IN NS servidor.hugocm.local.  

Fix permissions:

sudo chown bind:bind /var/cache/bind/db.56.168.192.in-addr.arpa  
sudo chmod 664 /var/cache/bind/db.56.168.192.in-addr.arpa  

---

## **Declare reverse zone in BIND9**

zone "56.168.192.in-addr.arpa." {  
    type master;  
    file "/var/cache/bind/db.56.168.192.in-addr.arpa";  
    allow-update { key ddns-key; };  
};  

Also in DHCP:

zone 56.168.192.in-addr.arpa. {  
    primary 192.168.56.10;  
    key ddns-key;  
};  

---

## **Final tests**

Direct resolution:

dig cliente.hugocm.local @192.168.56.10

Reverse resolution:

dig -x 192.168.56.20 @192.168.56.10

---

## **Resumen final**

1. El servidor DHCP asigna IP dinámicas en 192.168.56.20-30.  
2. BIND9 actualiza automáticamente la zona directa **hugocm.local** y la inversa **56.168.192.in-addr.arpa**.  
3. Se verifica con *dig* que **cliente.hugocm.local ↔ 192.168.56.20** funciona en ambas direcciones.  




