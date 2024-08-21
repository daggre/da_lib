--- Copyright © 2024 Joshua Nelson

---Get the epoch and send it to the client on request
---@param source integer The source/client id of the request
---@return integer epoch The current epoch time
Lib.Net.RegisterServerCb('util:epoch', function(source) return os.time() end)
