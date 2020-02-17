# TAPS (Tezos Automatic Payment System)

**TAPS** enables Tezos Bakers to automate rewards distribution with a web-page like interface.

It is written in CFML language (Coldfusion/Lucee). This repository contains all needed source code to run. However, there are some requirements.

## Getting started

To use this software you need to be a Tezos Baker with good experience. Follow the installation instructions below.
Two articles may be a good start:

[Bakers on Holiday](https://medium.com/@lmilfont/bakers-on-holiday-6b15b300f0b1)

[Installing Tezos TAPS](https://medium.com/@lmilfont/installing-tezos-taps-382adedd6a0f)


## TAPS Installation

1) Download Lucee Server from [https://download.lucee.org/](https://download.lucee.org/)
2) Download H2 Database from Lucee Extensions [https://download.lucee.org/](https://download.lucee.org/)
3) Install Lucee.
   - Get root privileges for the download folder, click with right mouse button over Lucee icon and choose OPEN.
   - Go through Lucee setup wizard, maintaining default installation options.
   - Choose a password for Lucee administration and write it down in a piece of paper.
   - Configure Lucee to start at every boot.
   - DON'T install Apache connector. We will use Lucee only for localhost (not Internet).
   - After Lucee installation, test it in browser with: http://127.0.0.1:8888/

   You can start/stop Lucee Application Server with:
   
       sudo /opt/lucee/lucee_ctl [start] [stop]

4) Install H2 Database.
   - Copy the downloaded file /home/[user]/downloads/org.h2-1.3.172.lex to folder /opt/lucee/tomcat/lucee-server/deploy/
   - Wait a minute. Lucee detects the extension and installs it automatically. That's it!

5) On Command Line Interface, go to folder (CD): /opt/lucee/tomcat/webapps (Debian) or /opt/lucee/tomcat/webapps/ROOT (UBUNTU).

6) Install TAPS.

   - Clone TAPS from GitHub with: git clone https://github.com/TezosRio/taps.git
   - Start TAPS in your browser with http://127.0.0.1:8888/taps/index.cfm
   - Log in TAPS with default user/pass: admin/admin.
   
   Note: On (some) UBUNTU installations TAPS folder must be in /opt/lucee/tomcat/webapps/ROOT/
   
7) Usage.
   - Go to TAPS SETUP page and enter your Baker's details. TAPS starts in simulation mode,
     so, don't worry, any real transfers will be done.
        

## Upgrading TAPS

These step-by-step instructions should be followed if you already have Taps installed on your system and want to UPGRADE to a new version available at gitHub:

1) (Always!) Write down in a piece of paper your Taps Native Wallet mnemonic words and passphrase.

2) Stop Lucee server with the command: sudo /opt/lucee/lucee_ctl stop

3) Backup your current Taps folder (/opt/lucee/tomcat/webapps/taps or /opt/lucee/tomcat/webapps/ROOT/taps) to some directory outside Lucee directory tree (this way if things go wrong, you may undo).

4) Open a Terminal prompt and go to current Taps folder: cd /opt/lucee/tomcat/webapps/taps

5) Now we are going to update it from github repository with the commands:

   sudo git fetch --all
   
   sudo git reset --hard origin/master
   
   
6) Start Lucee with the command:  sudo /opt/lucee/lucee_ctl start

7) Open Taps from your preferred browser with: http://127.0.0.1:8888/taps/index.cfm. It should now show the latest version.


## Disclaimer

This software is at Beta stage. It is currently experimental and still under development.
Many features are not fully tested/implemented yet.

## Resources
- [Issues][project-issues] — To report issues, submit pull requests and get involved (see [MIT License][project-license])

## Features

- Native Wallet: Can be used as the funds resource to pay rewards to delegators.
- Automatically distributes Tezos rewards to delegators when a cycle change happens.
- User/Password protected access.
- Custom individual delegator fee definition.
- Generates payment logs.
- Stores payments history.
- Batch Transaction Payments!
- Bond Pool configuration and automatic payments!
- (FIXED) Six decimal places accuracy payment - Solves "So-So" annotation on BakingBad.
- (FIXED) Page "PAYMENTS" and PDF report were showing 2 decimal places.
- (NEW!) Easier SETUP. Now there is only the native wallet option and Lucee details were removed.
- (NEW!) "SETTINGS" page lets user configure key aspects like:
         - Default Tezos RPC provider
         - Gas Limit and Storage Limit
         - Default transaction fee
         - EDIT Default baker rewards fee
         - EDIT Update (fetch) frequency
         - EDIT Proxy Server settings

- (NEW!) Now Taps really checks if rewards payments transactions were applied to the Tezos blockchain and saves the transaction hash for later checking in the "PAYMENTS" menu. User may configure how many times to retry to distribute rewards if Taps has failed to pay the first time.
- (NEW!) Now it is possible to DELEGATE from Taps native wallet to your preferred baker.



## Credits

- TAPS is a [Tezos.Rio](https://tezos.rio) team open-source product.

## License

**TAPS** is available under the **MIT License**.

[project-issues]: https://github.com/TezosRio/TAPS/issues
[project-license]: LICENSE.md
