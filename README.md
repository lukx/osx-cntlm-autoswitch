# CNTLM Config Switcher

This script will switch your cntlm config based on the current IP you are assigned to.
It is intended to work on macOS.

## Assumptions

* you have cntlm installed as a service via [brew](https://brew.sh/)
* you have two network locations configured in OSX Network Settings:
	* one (in our sample: "Coproprate") pointing http proxy and https proxy to your local CNTLM
	* one (in our sample: "Home") using no proxy at all

## Setting up
Copy the two `*.sample` files to non-sample files and fill in your values as documented in the file.

You can use `./proxy.sh -p` to help auto-fill your password hash to cntlm.Corporate.conf

## Running
Simply run ./proxy.sh
It will
* detect whether you are within the configured network range
* switch out your cntlm config & reload the cntlm service
* switch your macOS network location accordingly
* tell some specific tools (npm) to bypass or enable the cntlm proxy.
