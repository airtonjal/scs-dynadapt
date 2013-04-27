local oo           = require "loop.base"
local oil          = require "oil"
require "scs.core.arch.utils.ArchConfig"
require "scs.core.arch.utils.ArchUtils"

-- If we stored a broker instance previously, use it. If not, use the default broker
local oil = oil
--oil.verbose:level(1)

local ip = getIP()

local orb = getORB(oil)

local scs          = require "scs.core.base"
local scsAdaptive  = require "scs.core.adaptive"
local arch         = require "scs.core.arch.ArchManager"

-- Load idls
print("Loading IDLs")
local IDL_HOME = os.getenv("IDL_PATH")
loadIDL(IDL_HOME, orb)
print("Loaded succesfully")

if (arch) then print("Starting manager")   arch.startManager()
else           print("Could not aquire arch") os.exit(1)
end

print("arch_start.lua OK")

