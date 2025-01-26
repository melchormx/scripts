# Script: reglas para dns-local.
# 2025-01 / Melchor

# IP del DNS en nuestra red local.
:local IPDNSLocal "192.168.175.253"

# Crea una instancia de FIB para gestionar la ruta específica del DNS local.
/routing/table
add fib name=routing_test-01 \
	comment="melchormx::test-01"

