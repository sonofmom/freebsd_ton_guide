# FreeBSD Telegram Open Network installation guide
## Building and installing Telegram Open Network software on FreeBSD
This guide outlines process of building, installing and running of Telegram Open Network validator code on FreeBSD 12.x hosts.

This guide is first part of a series of 3 guides that will help you to build, configure and launch TON Full Node or Validator on a network of your choice but with the focus on [Newton Blockchain](https://github.com/newton-blockchain) Testnet in examples.

# Chapter 1: Building software
## Prerequesites
1. FreeBSD 12.x host (or jail)
2. Base distribution (no src or ports)
3. 4 Gigabytes of disk space in build directory

### Packages
Following packages are required in order to build the TON code: *cmake llvm libmicrohttpd ccache*

***Attention***: do not install *abseil* from packages, it does not work with latest ton source tree and will cause compilation errors. If abseil is not present on the system TON will use it's own version and that will work.

## Build process
### Clone the repository
Full internet access is needed at this stage.
> git clone https://github.com/newton-blockchain/ton.git

Please note that we are using `newton` fork of ton because it contains some important adjustments.

#### Initialize submodules
> cd ton\
git submodule init\
git submodule update

### Compilation
Ton source tree utilizes cmake build procedure, unlike good old *./configure; make; make install* the cmake build is done in a separate directory, usually it is created under the root of source tree and named *build*. I assume that you created such directory and entered it, now run:
> cmake ..

This is equivalent to `./configure` and will create Makefiles in the directory you are currently in. To execute compile, now run:
> make -jN

Where *N* is number of parallel compilation processes your hardware can support. I usually define 32 here since I have dual 8 core (16 cores / 32 threads) CPUs on my compillation host. If all worked well you should have a completed compile, my dual E5-2630v3 machine compiles entire source in ~10 minutes with 32 threads on SATA SSD volume.

### Making distribution
Official howtos from https://test.ton.org skip this step, they use binaries under build directory, but this is not a very good idea because build directory is huge and contains a lot of not needed stuff plus the binaries are not stripped (they contain debug symbols) and thus very bloated!

Ton makefiles contain wonderful installation script that will create a clean and orderly distribution tree with proper structure (bin,include,lib). In order to invoke them please run:
> cmake -DCMAKE_INSTALL_DO_STRIP=1 -DCMAKE_INSTALL_PREFIX=./dist -P cmake_install.cmake

This will install TON distribution (stripped binaries, libs and includes) into `dist` under your build directory.

### Installing software
#### Distribution files
Until proper package for FreeBSD is made (this is on my ToDo list) I prefer to place ton files into their own directory and not mix them with directories that contain files from other packages. This way I can easily remove / replace entire TON distribuition. I chose `/usr/local/opt/ton` as installation location for distribution. This is semi-conform with FreeBSD filesystem hierarchy (for more on that: `man hier`).
> sudo mkdir -p /usr/local/opt/ton\
sudo cp -R ./dist/* /usr/local/opt/ton

#### Data / work directory
TON Node stores it's data, automated configurations as well as logs under data directory (also known as work directory). In official TON guides this directory is called `/var/ton-work` but it can be anything you wish, this is a parameter you pass to binaries. In my case, I will again follow FreeBSD filesystem hierarchy schema and use `/var/db/ton` as data directory.
> sudo mkdir -p /var/db/ton

Please note that this is the place where ton will store and manipulate data, it needs a lot of space and fast file system (ssd!). I advise to make a separate zfs filesystem with a set quota to make sure that ton does not overflow other file systems.\
If you use zfs then I also advise to enable compression on this filesystem as ton data does not seem to be compressed and compression helps i/o performance.

#### User
This is optional step but I highly advise to run ton under special non-priveledged user, in this example I will name the user *tond*:
> sudo pw groupadd -n ton\
sudo pw useradd -n tond -c "TON Daemon" -g ton -s "/sbin/nologin" -d "/var/db/ton"\
sudo chown tond:ton /var/db/ton\
sudo chmod 750 /var/db/ton

# Chapter 2: Running node
This chapter outlines how to run the actual node. You must have a working node configuration to proceed. Please consult chapters 1 to 3 of [FreeBSD Telegram Open Network full node configuration guide](./freebsd_ton_fullnode_config.md) on how to do that.

## Prerequesites / assumptions
1. existance of node *global configuration* `/var/db/ton/newton-testnet-node/etc/global_config.json`
2. existance of node *local configuration* `/var/db/ton/newton-testnet-node/db/config.json`
3. ability to start the *validator-engine* with node configuration
4. outgoing UDP access to internet
5. incoming UDP access from internet to the port specified during node configuration

We also assume that you chose to create a dedicated user *tond* and initialized the configuration using that user.

### Software / OS
* FreeBSD 12.x host (or jail)
* Base distribution

## Step a: Install daemontools
While not required, this is highly advised and all of my further instructions are based on this package.

### Why daemontools
* Service monitoring / restart in case of service crash
* Easy service control

For more information, please see: https://cr.yp.to/daemontools.html
> sudo pkg install daemontools\
sudo mkdir /var/service\
sudo service svscan enable\
sudo service svscan start

## Step b: Enable node control via daemontools
### Create service directory
> sudo mkdir /var/service/.newton-testnet-node

Note that we are prefixing the directory name with a dot, this makes service directory invisible to svscan as we do not want things to start something until we are finished with configuring.

### Disable auto-start of the service
> sudo touch /var/service/.newton-testnet-node/down

This is optional, only if you do not wish service to auto-start.

### Fetch and edit run script
Download the [run](./support/service/newton-testnet-node/run) file into `/var/service/.newton-testnet-node` directory and make it executable.

> sudo fetch https://raw.githubusercontent.com/sonofmom/freebsd_ton_guide/master/support/service/newton-testnet-node/run -o /var/service/.newton-testnet-node/run\
sudo chmod 755 /var/service/.newton-testnet-node/run

**Make sure you review the file content and adjust the variables to your dht server configuration.**

### Test run script
> sudo /var/service/.newton-testnet-node/run

If all is correct then the validator node will start as foreground process. If not, please review your instance *log files*

### Make service visible to svscan
> sudo mv /var/service/newton-testnet-node /var/service/newton-testnet-node

### Test if service can be started using svscan
> sudo svc -u /var/service/newton-testnet-node

Now wait 2-3 seconds and issue 

> sudo svstat /var/service/newton-testnet-node

If all went OK then you should see following message: `/var/service/newton-testnet-node: up (pid 65713) 3 seconds, normally down` where pid and seconds will be different on your system of course.

### Enable automatic start of service
> sudo rm /var/service/newton-testnet-node/down

# Chapter 3: Running dht server
This chapter outlines how to run the dht server. You must have a working dht server configuration to proceed. Please consult chapters 1 to 3 of [FreeBSD Telegram Open Network dht server configuration guide](./freebsd_ton_dht_config.md) on how to do that.

## Prerequesites / assumptions
1. existance of node *global configuration* `/var/db/ton/newton-testnet-dht/etc/global_config.json`
2. existance of node *local configuration* `/var/db/ton/newton-testnet-dht/db/config.json`
3. ability to start the *dht-server* with node configuration
4. outgoing UDP access to internet
5. incoming UDP access from internet to the port specified during dht server configuration

We also assume that you chose to create a dedicated user *tond* and initialized the configuration using that user.

### Software / OS
* FreeBSD 12.x host (or jail)
* Base distribution

## Step a: Install daemontools
Please see chapter 2a on how to do that.

## Step b: Enable dht server control via daemontools
### Create service directory
> sudo mkdir /var/service/.newton-testnet-dht

Note that we are prefixing the directory name with a dot, this makes service directory invisible to svscan as we do not want things to start something until we are finished with configuring.

### Disable auto-start of the service
> sudo touch /var/service/.newton-testnet-dht/down

This is optional, only if you do not wish service to auto-start.

### Fetch and edit run script
Download the [run](./support/service/newton-testnet-dht/run) file into `/var/service/.newton-testnet-dht` directory and make it executable.

> sudo fetch https://raw.githubusercontent.com/sonofmom/freebsd_ton_guide/master/support/service/newton-testnet-dht/run -o /var/service/.newton-testnet-dht/run\
sudo chmod 755 /var/service/.newton-testnet-dht/run

**Make sure you review the file content and adjust the variables to your dht server configuration.**

### Test run script
> sudo /var/service/.newton-testnet-dht/run

If all is correct then the dht server will start as foreground process. If not, please review your instance *log files*

### Make service visible to svscan
> sudo mv /var/service/.newton-testnet-dht /var/service/newton-testnet-dht

### Test if service can be started using svscan
> sudo svc -u /var/service/newton-testnet-dht

Now wait 2-3 seconds and issue 

> sudo svstat /var/service/newton-testnet-dht

If all went OK then you should see following message: `/var/service/newton-testnet-dht: up (pid 65713) 3 seconds, normally down` where pid and seconds will be different on your system of course.

### Enable automatic start of service
> sudo rm /var/service/newton-testnet-dht/down

## Congratulations
By this step you should have a running TON Node and / or dht server.

But this is just a beginning, you need to configure quite a lot, please see
* [FreeBSD Telegram Open Network full node configuration guide](./freebsd_ton_fullnode_config.md): Describes process of configuring TON network full node.
* [FreeBSD Telegram Open Network validator node configuration guide](./freebsd_ton_validator_config.md): Describes process of configuring TON network full node.