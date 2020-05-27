# Synopsis
This is set of guides that outlines a process of bootstrapping Telegram Open Network node (full node or validator) on FreeBSD systems.

This guide shows how to start a node for [Newton Blockchain](https://github.com/newton-blockchain) Testnet but can be used to start a node for any other blockchain as well.

## Why
There are few guides and ready solutions for TON Blockchain nodes but most of them are either focused on Linux or provide docker image, neither of those are good solutions if you wish to run node on FreeBSD systems.

## Status
Please note that this document is under heavy development, I am planning to improve guides in next days / weeks as well as create full binary package for FreeBSD to eliminate the need to compile and manually install the software.

## Content
* [FreeBSD Telegram Open Network installation guide](./freebsd_ton_installation.md): Describes process of building, installing and running TON binaries on FreeBSD systems.
* [FreeBSD Telegram Open Network full node configuration guide](./freebsd_ton_fullnode_config.md): Describes process of configuring TON network full node.
* [FreeBSD Telegram Open Network validator node configuration guide](./freebsd_ton_validator_config.md): Describes process of configuring TON network full node.
* [FreeBSD Telegram Open Network dht server configuration guide](./freebsd_ton_dht_config.md): Describes process of configuring TON network dht server.
* [FreeBSD Telegram Open Network FAQ](./freebsd_ton_faq.md): FAQ on TON for FreeBSD (and other systems).
