# Script: reglas para dns-local.
# 2025-01 / Melchor

# IP del DNS en nuestra red local.
:local IPDNSLocal "192.168.175.253"

# Crea una instancia de FIB para gestionar la ruta específica del DNS local.
/routing/table
add fib name=routing_dns-local \
	comment="melchormx::routing_dns-local"

# Agrega una ruta estática predeterminada específica para el enrutamiento hacia el DNS local.
/ip/route
add distance=1 dst-address=0.0.0.0/0 \
	gateway=$IPDNSLocal routing-table=routing_dns-local \
	comment="melchormx::route_dns-local"

# Agrega en una lista de direcciones las IPs de los DNS para que resuelvan usando nuestro DNS local.
/ip/firewall/address-list
add address=8.8.8.8 list=LOCAL-DNS comment=Google-1 
add address=8.8.4.4 list=LOCAL-DNS comment=Google-2
add address=208.67.222.222 list=LOCAL-DNS comment=OpenDNS-1
add address=208.67.220.220 list=LOCAL-DNS comment=OpenDNS-2
add address=1.1.1.1 list=LOCAL-DNS comment=Cloudflare-1
add address=1.0.0.1 list=LOCAL-DNS comment=Cloudflare-2
add address=9.9.9.9 list=LOCAL-DNS comment=Quad9-1 
add address=149.112.112.112 list=LOCAL-DNS comment=Quad9-2

# Marca paquetes TCP (53, 443, 853) y UDP (53) que tengan con destino alguna de las IPs
# en la lista de direcciones previamente definida.
/ip/firewall/mangle
add action=mark-packet chain=prerouting dst-address-list=LOCAL-DNS dst-port=53,443,853 \
    new-packet-mark=mark_local-dns passthrough=yes protocol=tcp \
    comment="melchormx::mark-paccket_local-dns-tcp"
add action=mark-packet chain=prerouting dst-address-list=LOCAL-DNS dst-port=53 \
	new-packet-mark=mark_local-dns passthrough=yes protocol=udp \
	comment="melchormx::mark-paccket_local-dns-udp"

# Marca el enrutamiento de paquetes previamente marcados hacia nuestro DNS local.
add action=mark-routing chain=prerouting \
	new-routing-mark=routing_dns-local packet-mark=mark_local-dns passthrough=no \
	comment="melchormx::forward-to-local-dns"
