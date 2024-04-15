# Daggre Actual's Library (da_lib)
## Version & Status
v0.8 - Early Release

## Description
Library of utilities and tools for use in support of other scripts.

## Installation
Clone the **da_lib** repository into your servers resources folder:
```
cd resources
git clone git@github.com:daggre/da_lib.git
```
Add `ensure da_lib` to your preferred resource config. (Default: server.cfg)

## Usage
This resource provides a library for other scripts to use. To use this
library import it into your working script:
```
da = exports.da_lib:importLib()
```
Once imported you can reference utilities and functions within the **da_lib**.

- API
- Audio
- Cache
- Draw
- Fn
- Lock
- Log
- Net
- Obj
- Ped
- Props
- String
- Time
- Util
- Zone
- PolyZone

## Support
Discord: daggre
Discord Server: TBA

## Authors and Acknowledgment
daggre_actual
