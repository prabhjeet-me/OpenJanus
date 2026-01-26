# OpenJanus

A dockerize fast, scalable & high-performance web server by extending [OpenResty](https://github.com/openresty/openresty) _(which further extends nginx with lots of 3rd-party modules)_. This extension provides certbot automation for certbot configuration and renewal, WireGuard VPN. This also generates a Diffie-Hellman (DH) param automatically for secure SSL/TLS connection enhancing Perfect Forward Secrecy (PFS). This extension ensures a more robust key exchange mechanism out of the box.

## Architecture Diagram

The diagram below outlines how the system is structured

![Alt text](./docs/architecture.svg)
