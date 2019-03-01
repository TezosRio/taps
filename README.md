# TAPS (Tezos Automatic Payment System)

**TAPS** enables Tezos Bakers to automate rewards distribution.

It is written in CFML language (Coldfusion/Lucee). This repository contains all needed source code to run. However, there are some requirements.

## Getting started

To use this software you need to be a Tezos Baker with good experience. Follow the installation instructions below.
Two articles may be a good start:

[https://medium.com/@lmilfont/bakers-on-holiday-6b15b300f0b1](Bakers on holiday)
[https://medium.com/@lmilfont/installing-tezos-taps-382adedd6a0f](Installing Tezos TAPS)


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

5) Clone TAPS from GitHub with:

   git clone https://github.com/TezosRio/taps.git

6) Install TAPS.
   - Copy TAPS folder to /opt/lucee/tomcat/webapps/
   - Start TAPS in your browser with http://127.0.0.1:8888/taps/index.cfm
   - Log in TAPS with default user/pass: admin/admin.
   
7) Usage.
   - Go to TAPS SETUP page and enter your Baker's details. TAPS starts in simulation mode,
     so, don't worry, any real transfers will be done.
        

## Disclaimer

This software is at Beta stage. It is currently experimental and still under development.
Many features are not fully tested/implemented yet.

## Resources
- [Issues][project-issues] — To report issues, submit pull requests and get involved (see [MIT License][project-license])

## Features

- (NEW!) Native Wallet: Can be used as the funds resource to pay rewards to delegators.
- Automatically distributes Tezos rewards to delegators when a cycle change happens.
- User/Password protected access.
- Custom individual delegator fee definition.
- Generates payment logs.
- Stores payments history.

## Credits

- TAPS is a [Tezos.Rio](https://tezos.rio) team open-source product.
- TAPS uses [TzScan.io](https://tzscan.io) API to fetch information from the Tezos blockchain.
- TAPS uses [Tezos-client](https://tezos.com) software to make transfers and inject operations on Tezos blockchain.

## License

**TAPS** is available under the **MIT License**.

[project-issues]: https://github.com/TezosRio/TAPS/issues
[project-license]: LICENSE.md
