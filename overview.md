# OpenJanus

An open-source, containerized infrastructure stack combining OpenResty, automatic SSL, and a built-in WireGuard VPN to securely expose public and private endpoints with minimal configuration and operational overhead.

## Docker Compose

```yml
services:
  openjanus:
    image: prabhjeetme/openjanus:latest
    container_name: openjanus
    restart: always
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    environment:
      - CB_TESTING=0
      - CB_EMAIL=dev@example.com
      - CB_DOMAINs=example.com app1.example.com
      - WG_PEERS=phone:10.13.13.2,tablet:10.13.13.3
      - VPN_ENDPOINT=vpn.example.com
      - VPN_PORT=51820
      - SERVER_PUBLIC_IP=xx.xx.xx.xx
    ports:
      - "80:80"
      - "443:443"
      - "51820:51820/udp"
    volumes:
      - ./configs/conf:/etc/openjanus/conf:ro # Nginx config
      - ./configs/stream:/etc/openjanus/stream:ro # Nginx steam config
      - ./volumes/letsencrypt:/etc/letsencrypt # SSL certificates
      - ./volumes/openjanus/ssl:/etc/openjanus/ssl # Stores DH param
      - ./volumes/openjanus/var:/var/lib/openjanus # Stores run state
      - ./volumes/wireguard:/etc/wireguard # VPN configs
```

## Environment Variables

| Variable Name    | Required | Default        | Description                                                                                                          |
| :--------------- | :------: | :------------- | :------------------------------------------------------------------------------------------------------------------- |
| CB_EMAIL         |   True   |                | Email required by certbot for account registration and for contacting in case of any issue.                          |
| CB_DOMAINs       |   True   |                | Space separated CB_DOMAINs that are needed to be registered **(No wildcards)**                                       |
| CB_CRON_PATTERN  |  False   | 30 20 \* \* \* | Certbot renewal cronjob to renew due certificates.                                                                   |
| CB_TESTING       |  False   | 0              | Provide 1 (instead of 0) for test mode. Sets --staging (in case of domain challenge) & --dry-run (in case of renew). |
| SERVER_PUBLIC_IP |   True   | _blank_        | Server's public IP where container is container is deployed.                                                         |
| VPN_ENDPOINT     |   True   | _blank_        | VPN Endpoint.                                                                                                        |
| VPN_PORT         |  False   | 51820          | 51820 default WireGuard port. Change if a different port is mapped on host.                                          |
| SSL_DH_SIZE      |  False   | 2048           | DH param size. File is generated on first run                                                                        |

## Production Deployment

1. Use above configuration as the base template.
2. Update environment variables for your site.
3. It is necessary to mount directories (mentioned above) for persistence.
4. Put your nginx configs in _conf_ & _stream_ directory.
5. Make sure you have created records for all DNS mentioned in _CB_DOMAINs_ & _VPN_ENDPOINT_.
6. Make sure VPN_PORT is allowed on firewall.
7. Run the container using `docker compose up -d`.

_For more information visit [OpenJanus Repository](https://github.com/prabhjeet-me/OpenJanus) on GitHub._
