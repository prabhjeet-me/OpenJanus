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
