# OpenJanus

An open-source, containerized infrastructure stack combining OpenResty, automatic SSL, and a built-in WireGuard VPN to securely expose public and private endpoints with minimal configuration and operational overhead.

## Architecture Diagram

The diagram below outlines how the system is structured

![Architecture Diagram](./docs/architecture.svg)

## Prerequisites

Install required softwares ([Docker](https://www.docker.com/get-started/) & [Visual Studio Code](https://code.visualstudio.com/)). This will allow one click setup & dockerize development. After installation open this project in devcontainer.

## Terminology

1. DH: Diffie-Hellman

## Project Structure

| Directory                | Description                         |
| :----------------------- | :---------------------------------- |
| [/container](/container) | Files to be bundled build container |
| [/docs](/docs)           | Documents (like architecture)       |
| [/pages](/pages)         | Nunjucks pages for error pages      |
| [/scripts](/scripts)     | Scripts (like build)                |

## Build

Run `npm run build` to build the docker image.

## Environment Variables

| Variable Name    | Required | Default        | Description                                                                                                          |
| :--------------- | :------: | :------------- | :------------------------------------------------------------------------------------------------------------------- |
| CB_EMAIL         |   True   |                | Email required by certbot for account registration and for contacting in case of any issue.                          |
| CB_DOMAINs       |   True   |                | Space separated CB_DOMAINs that are needed to be registered **(No wildcards)**                                       |
| CB_CRON_PATTERN  |  False   | 30 20 \* \* \* | Certbot renewal cronjob to renew due certificates.                                                                   |
| TEST             |  False   | 0              | Provide 1 (instead of 0) for test mode. Sets --staging (in case of domain challenge) & --dry-run (in case of renew). |
| SERVER_PUBLIC_IP |   True   | _blank_        | Server's public IP where container is container is deployed.                                                         |
| VPN_ENDPOINT     |   True   | _blank_        | VPN Endpoint.                                                                                                        |
| VPN_PORT         |  False   | 51820          | 51820 default WireGuard port. Change if a different port is mapped on host.                                          |
| SSL_DH_SIZE      |  False   | 2048           | DH param size. File is generated on first run                                                                        |
