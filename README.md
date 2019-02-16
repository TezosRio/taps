# TAPS (Tezos Automatic Payment System)

**TAPS** enables Tezos Bakers to automate rewards distribution.

It is written in CFML language (Coldfusion/Lucee). This repository contains all needed source code to run. However, there are some requirements.

## Getting started

Just follow the step-by-step guide below.

## Disclaimer

This software is at Beta stage. It is currently experimental and still under development.
Many features are not fully tested/implemented yet.

## Resources
- [Issues][project-issues] — To report issues, submit pull requests and get involved (see [MIT License][project-license])

## Features

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
