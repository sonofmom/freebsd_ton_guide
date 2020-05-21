# FreeBSD Telegram Open Network full node configuration guide
## Configuration and initialization of TON full node
This guide outlines process of conifguration and initialization of full node / validator for Telegram Open Network based blockchain networks on FreeBSD host, based on example of [Newton Blockchain](https://github.com/newton-blockchain) Testnet.

Following this guide you should be able to spawn nodes for other networks as well, even on the same machine / virtual host if you desire.

## Prerequesites / assumptions
Completion of chapter 1 of [FreeBSD Telegram Open Network installation guide](./freebsd_ton_installation.md) and as a result:

* Compiled and installed distribution under `/usr/local/opt/ton`
* Presence of `/usr/local/etc/ton` global configuration directory
* Presence of `/var/db/ton` data directory
* Access to internet from the host

We also assume that you chose to create a dedicated user called *tond* and this user has read/write access to `/var/db/ton` directory. You can substitute this username for any other user, just make sure that this account can access `/var/db/ton`.


## Chapter 1: Create work directory for your node
If you run more then one node on one host you should place have a separate work directory for each node under global ton data directory. In our example node work directory will be named: `/var/db/ton/newton-testnet`. 

> sudo -u tond mkdir -p /var/db/ton/newton-testnet/{etc,db,log}

This should work if you have a user *tond* and this user has r/w rights to `/var/db/ton`

### Result
We have created a work directory for our ton node.

## Chapter 2: Download global network configuration
Configuration of each TON node begins with downloading of *global configuration* file for your network.
This file contains some basic information about network, for example it specifies at least one node with fixed IP address from which ton software can download additional network information.

Each network (Newton testnet, TFC testnet, TON testnet2, Freeton etc.) has it's own *global configuration* file. Source of those files depends on the network. We will be using [Newton Blockchain testnet global configuration file](https://raw.githubusercontent.com/newton-blockchain/newton-blockchain.github.io/master/newton-test.global.config.json):

> sudo -u tond fetch https://raw.githubusercontent.com/newton-blockchain/newton-blockchain.github.io/master/newton-test.global.config.json -o /var/db/ton/newton-testnet/etc/global_config.json

After this file you should have a file `/var/db/ton/newton-testnet/etc/global_config.json` with some data in it. Please do not edit this file, there is nothing what you as node operator can and need to change there.

### Result
We have downloaded global configuration file for our node, now we can connect to the network.

## Chapter 3: Initialize local configuration
Next step is to create *local configuration* using *global configuration* file downloaded in previous step.

> sudo -u tond /usr/local/opt/ton/bin/validator-engine -C /var/db/ton/newton-testnet/etc/global_config.json --db /var/db/ton/newton-testnet/db --ip <IP>:<PORT> -l /var/db/ton/newton-testnet/log/init.log

Replace <IP> and <PORT> with fixed public IP of your node and PORT number of your choice, I would advise to use high port number beginning from 20000. 

This command will run and exit without any output but if execution was success then local configuration file `/var/db/ton/newton-testnet/db/config.json` would be generated. If the file is not there then something went wrong, check *log files*.

***Important***: Please note that the command used here is pretty much identical to the one that is used to run actual node. If the *local configuration* file already exists then you will start a node. (command will not exit automatically). This is not a problem, just break it off (ctrl_c).

### Result
We have generated a *local configuration* file `/var/db/ton/newton-testnet/db/config.json` for our node. This file contains quite a few things: our IP address, network port, generated adnl address etc. This is the holy grail of our node.

Essentially, this is it: your machine can operate as a network node, you can try and start it by running:

> sudo -u tond /usr/local/opt/ton/bin/validator-engine -C /var/db/ton/newton-testnet/etc/global_config.json --db /var/db/ton/newton-testnet/db -l /var/db/ton/newton-testnet/log/node.log

If all went well then this command should stay in foreground as long as you do not kill it. Check out the log files for information on what is going on.

#### Automate the node
It is at this step that I advise you to automate start/stop of the node as a system service, I strongly advise to utilize _daemontools_ do do that, please consult Chapter 2 of [FreeBSD Telegram Open Network installation guide](./freebsd_ton_installation.md).

### Sidenote: Log files
It is important to understand architecture of *validator-engine* in order to understand log file structure: *validator-engine* acts as a **main process** that takes the command arguments, loads configs and then spawns **children processes / threads** that do actual job. Each process / thread writes into *it's own log file*.

The log file you specify with *-l* parameter points to log file used by **main process**, each **thread** writes it's own log file that has `.threadN.log` appended to name of main log file. Where N is number of the thread.

As a result, during initiation two logs will be made:

* `/var/db/ton/newton-testnet/log/init.log` that ideally should be empty
* `/var/db/ton/newton-testnet/log/init.log.thread1.log` that will contain information from the thread that actually made the _local configuration_

## Step 4: Controling your node
Having a working node is great success but it is of not much use if you cannot control / access it. In order to do this we need to setup remote control CLI access.
**TODO**

## Step 5: Liteserver and client
**TODO**