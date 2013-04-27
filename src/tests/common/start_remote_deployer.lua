local oo           = require "loop.base"
local oil          = require "oil"
require "scs.core.arch.utils.ArchConfig"
require "scs.core.arch.utils.ArchUtils"

-- If we stored a broker instance previously, use it. If not, use the default broker
--oil.verbose:level(0)
local ip = getIP()
local filename = debug.getinfo(1).source

local orb = getORB(oil)

local deployer     = require "scs.core.arch.start_deployer"

if (deployer) then print("Starting deployer")         startDeployer()
else               print("Could not aquire deployer") os.exit(1)
end

print(filename .. " OK")

