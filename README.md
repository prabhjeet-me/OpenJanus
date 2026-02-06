# OpenJanus

An open-source, containerized infrastructure stack combining OpenResty, automatic SSL, and a built-in WireGuard VPN to securely expose public and private endpoints with minimal configuration and operational overhead.

![developed by](https://img.shields.io/badge/developed_by-Prabhjeet_Singh-blue)
[![license](https://img.shields.io/github/license/prabhjeet-me/OpenJanus)](https://github.com/prabhjeet-me/OpenJanus/blob/main/LICENSE)
![GitHub issues](https://img.shields.io/github/issues/prabhjeet-me/OpenJanus)
![CI](https://img.shields.io/github/actions/workflow/status/prabhjeet-me/OpenJanus/docker-build.yml)
![Repo Size](https://img.shields.io/github/repo-size/prabhjeet-me/OpenJanus)
![GitHub stars](https://img.shields.io/github/stars/prabhjeet-me/OpenJanus)
![GitHub forks](https://img.shields.io/github/forks/prabhjeet-me/OpenJanus)

![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/prabhjeetme/openjanus)
![Docker Image Version](https://img.shields.io/docker/v/prabhjeetme/openjanus)
![Docker Image Size](https://img.shields.io/docker/image-size/prabhjeetme/openjanus/latest)

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-View%20Image-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://hub.docker.com/r/prabhjeetme/openjanus)

## Architecture Diagram

The diagram below outlines how the system is structured

![Architecture Diagram](./docs/architecture.svg)

## Prerequisites

Install required softwares ([Docker](https://www.docker.com/get-started/) & [Visual Studio Code](https://code.visualstudio.com/)). This will allow one click setup & dockerize development. After installation open this project in devcontainer.

## Terminology

1. DH: Diffie-Hellman

## Commands

| Command                  | Description                                                                     |
| :----------------------- | :------------------------------------------------------------------------------ |
| \* `npm run serve`       | Combines functionality of above. Run this if updating HTML, CSS content (watch) |
| \* `npm run build`       | Build image                                                                     |
| `npm run tailwind:watch` | Generate tailwind classes (watch)                                               |
| `npm run eleventy:watch` | Generate HTML from templates (watch)                                            |
| `npm run prettier:watch` | Format code (watch)                                                             |
| `npm run serveStatic`    | Serve generated HTML pages                                                      |
| `npm run build:pages`    | Build HTML, CSS content                                                         |

## Project Structure

| Directory                | Description                         |
| :----------------------- | :---------------------------------- |
| [/container](/container) | Files to be bundled build container |
| [/docs](/docs)           | Documents (like architecture)       |
| [/pages](/pages)         | Nunjucks pages for error pages      |
| [/scripts](/scripts)     | Scripts (like build)                |
| [/examples](/examples)   | Configuration examples              |

## Build

Run `npm run build` to build the docker image.

## Production Deployment

1. Use [docker-compose.yml](./docker-compose.yml) as the base template.
2. Update [environment variables](#environment-variables) for your site.
3. It is necessary to mount directories (mentioned in [docker-compose.yml](./docker-compose.yml)) for persistence.
4. Put your nginx configs in _conf_ & _stream_ directory.
5. Make sure you have created records for all DNS mentioned in _CB_DOMAINs_ & _VPN_ENDPOINT_.
6. Make sure VPN_PORT is allowed on firewall.
7. Run the container using `docker compose up -d`.

## Builtin Features

1. Preconfigured security headers in http block. These headers will be inherited in all of the _server_ blocks. If any application requires a different value for any header, it can be overwritten in server block of itself. See Overwrite header in this [example](/examples/overwrite_headers.example.conf)
2. Default error pages. Container comes with predefined error pages for 404 & 50x. Error pages can be overridden in [html](/html/) directory. If any server block needs to show overridden 50x page it has to add `location /50x.html{}` in server block (see [example](/examples/50x.example.conf)), otherwise the default OpenResty/Nginx 50x page will be served.
3. Best possible ssl & dhparam Nginx configurations (see [nginx.conf](/conf/nginx.conf)).

## Examples

1. Serving custom _50x_ page: Configuration to serve custom 50x page [here](/examples/50x.example.conf).
2. Serving custom _403_ page: Configuration to serve custom 403 page [here](/examples/403.example.conf).
3. One line configuration to do above 2 [here](/examples/common_conf.example.conf).
4. Override default headers: [This](/examples/overwrite_headers.example.conf) shows how to override default headers.
5. Setting SSL: SSL setup is demonstrated in [this](/examples/ssl.example.conf) example.
6. Stream TCP connection: To stream TCP connection, [this example](/examples/stream.example.conf) should be helpful (make sure stream port is mapped to host machine).

## Environment Variables

| Variable Name    | Required | Default      | Description                                                                                                          |
| :--------------- | :------: | :----------- | :------------------------------------------------------------------------------------------------------------------- |
| CB_EMAIL         |   True   |              | Email required by certbot for account registration and for contacting in case of any issue.                          |
| CB_DOMAINs       |   True   |              | Space separated CB_DOMAINs that are needed to be registered **(No wildcards)**                                       |
| CB_CRON_PATTERN  |  False   | 0 0 \* \* \* | Certbot renewal cronjob to renew due certificates.                                                                   |
| CB_TESTING       |  False   | 0            | Provide 1 (instead of 0) for test mode. Sets --staging (in case of domain challenge) & --dry-run (in case of renew). |
| SERVER_PUBLIC_IP |   True   | _blank_      | Server's public IP where container is container is deployed.                                                         |
| VPN_ENDPOINT     |   True   | _blank_      | VPN Endpoint.                                                                                                        |
| VPN_PORT         |  False   | 51820        | 51820 default WireGuard port. Change if a different port is mapped on host.                                          |
| SSL_DH_SIZE      |  False   | 2048         | DH param size. File is generated on first run                                                                        |

## Default Pages

Default pages like 50x, 403 & 404 is already configured to override with pages in [/container/html](/container/html/) directory (see [nginx.conf](/container/conf/nginx.conf)). Server block needs to include common.conf to actually override the content (See [Example no. 3](#examples)).

## SSL Analysis

For SSL analysis use [SSL Labs](https://www.ssllabs.com/ssltest/analyze.html).

## OpenResty - OpenJanus

| OpenResty Version | OpenJanus Version |
| :---------------- | :---------------- |
| 1.27.1.2-alpine   | 1.0.0-alpine      |

## Don'ts

1. Never mount a file named _default.conf_. This will replace internal _default.conf_ file. If overwrite is required, include [this file](/container/conf/default.conf) logic in your _default.conf_ file.

## Frequently Asked Questions (FAQs)

### Why I see a file named _.first_run_done_?

Open Janus creates this file as a flag to know if the container is being initially setup or is a subsequent run.

### I already have a domain (example.com) registered, I want to register a new domain (api.example.com). How should I do it?

From container's mounted volume remove file named _.first_run_done_ and restart the container with updated environment variables (space separated add new CB_DOMAINs). This will force container to execute initial setup. Doing so will extend existing certificate to add provided CB_DOMAINs.

### My application (say example server) is running (I'm able to ping the server inside container), but Nginx logs shows _Connection refused_ (or similar). What to do?

This situation generally comes when you run/restart the application container while Open Janus is still running (obviously). To fix this just run `nginx -s reload` command inside Open Janus container.

### I want to override default headers. How to do that?

See [Example no. 2](#examples)

### Why I'm seeing a default OpenResty 403/50x page?

These are default pages that are served by OpenResty. See [Example no. 1](#examples) & [Example no. 2](#examples) on how to override or better see [Example no. 3](#examples).

### Why nginx configs are copied to conf.d directory in entrypoint instead of mounting conf.d directly?

Because if directly mounted, on initial run, ssl in _server_ block will try to find the non-existing certificates. Once certbot generates the certificate and puts it in place, we copy configs to nginx configs to avoid container crash.

### What is the format for CB_DOMAINs?

Its space separated domains.

### What is the format for WG_PEERS?

Comma separated <DEVICE_NAME>:<PEER_IP>. Ex: `phone:10.13.13.2`. Note that same IP cannot be assigned to multiple users, for next user IP should be `10.13.13.3` and so on.

## Support This Project

If you find this project helpful, consider supporting my work.

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-support-yellow?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/prabhjeet.me)
