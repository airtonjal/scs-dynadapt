local oo          = require "loop.base"
local oil         = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"

local DEBUG = DEBUG
local filename =  debug.getinfo(1).source
local DEBUG_PREFIX = "[" .. filename .. "] "
local output = function(str) if (DEBUG) then print(DEBUG_PREFIX .. str) end end

local ip = getIP()

local _orb = getORB(oil)

local scs         = require "scs.core.base"
local scsAdaptive = require "scs.core.adaptive"
local composite   = require "scs.core.composite"
local Deployer    = require "scs.core.arch.Deployer"

local IDL_HOME = os.getenv("IDL_PATH")
output("Found IDL_PATH variable: " .. IDL_HOME .. "\tLoading IDLs ...")

loadIDL(IDL_HOME, _orb)

oil.main(Deployer.startDeployer)

