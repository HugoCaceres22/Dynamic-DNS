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





