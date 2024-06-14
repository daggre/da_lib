# Daggre Actual's Library (da_lib)
## Version & Status
v0.8 - Early Release

## Description
The da library is a collection of functions and utilities that are used in
implementation of RedM resources. The library is intended to be used as an aid
to developers by creating reliable and convenient ways to execute common coding
practice in RedM scripts given the capabilities of the RedM game.

### API Layer
The da library is also designed with an API layer to make calls into other game
frameworks, currently the TMC framework is supported. The API layer allows the
da library to call API functions, which then check to see which API is currently
configured and then calls that APIs relevant functionality. If an API is not
configured or implemented, then in the best case scenario we will try to return
a value which best enables the scripts functionality.

### Features
The da library has a number of features, including: animations, audio streaming,
caching, chance logic, loot tables, controller logic, particle fx, resource
locking, log levels, client server communication and callbacks,
object/vehicle/prop creation, interactive prompts, string manipulation, time
tracking, shape/line/text drawing, 3d math, and world zone management.

### Additonal Documentation
Additional documentation for each of the features can be found in the respective
folders as well as comments in the code.

## Usage
This resource provides a library for other scripts to use. To use this
library import it into your working script:
```lua
da = exports.da_lib:importLib()
```
It is also suggested to register a callback function for the log levels so that
RedM can properly log to the client console with respect to the script calling
each log, the following is standard:
```lua
da = exports.da_lib:importLib()
da.Log.Register(function(msg) print(msg) end)
```
This will set the log level to info for LIVE servers and debug for DEV servers.

## Installation
Clone the **da_lib** repository into your servers resources folder:
```bash
cd resources
git clone git@github.com:daggre/da_lib.git
```
Add `ensure da_lib` to your preferred resource config. (Default: server.cfg)

## Support
- Discord: daggre
- Discord Server: [da_dev](https://discord.com/invite/JgteBpXGaA)

## Authors and Acknowledgment
- daggre_actual
