local oo = require "loop.base"
local Deployer = require "scs.core.arch.Deployer"
require "scs.core.arch.utils.ArchConfig"
require "scs.core.arch.utils.ArchUtils"

local table_print   = table_print
local booleanString = booleanString
local getIP         = getIP
local _arch_package = _arch_package
local error         = error
local module        = module
local require       = require
local assert        = assert
local print         = print
local pairs         = pairs
local table         = table
local setmetatable  = setmetatable
local ipairs        = ipairs
local os            = os
local tostring      = tostring
local type          = type
local string        = string
local table         = table
local io            = io

local ARCH_HOME = os.getenv("ARCH_HOME")

local MODULE = "scs.core.arch.Machine"

local DEBUG = DEBUG
local DEBUG_PREFIX = "[" .. MODULE .. "] "

--local _debug = debug
--local getName = function() return debug.getinfo(2).name end
local debug = function(str) if (DEBUG) then print("[ DEBUG ] " .. DEBUG_PREFIX .. str) end end
local warn  = function(str) if (DEBUG) then print("[ WARN  ] " .. DEBUG_PREFIX .. str) end end
local info  = function(str) if (DEBUG) then print("[ INFO  ] " .. DEBUG_PREFIX .. str) end end

module (MODULE)

local SLEEP_PERIOD = 3

Machine = oo.class{
  ok = false
}

function Machine:__init(unique_name, host, port, user, pass)
  local self = oo.rawnew(self, {})
  
  assert(type(port)        == "number")
  assert(type(host)        == "string")
  assert(type(user)        == "string")
  assert(type(pass)        == "string")
  assert(type(unique_name) == "string")
  self.host = host
  self.port = port
  self.user = user
  self.pass = pass
  self.unique_name = unique_name
--  self:checkAvailability() 

  return self
end

function Machine:isLocalhost()
  if (self.host == "localhost" or self.host == "127.0.0.1") then return true else return false end
end

function Machine:isNumericHost()
  local o1, o2, o3, o4 = self.host:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)")
  if (o1 and o2 and o3 and o4) then return true else return false end
end

function Machine:checkAvailability()
  --os.execute("ssh ".. self.host .. " 'cd \"".. SCS_HOME .."/src/lua/scs/execution_node\" && screen -d -m ./run -host ".. machine.host .." -port ".. machine.port .."'")
  --os.execute(self:createSSH() .. " 'cd \"".. ARCH_HOME .."src/scs/core/arch/\" && screen -d -m lua start_deployer.lua && mkdir FUNFOU'")
  local cmd = self:createSSH() .. " \"" .. self:goToArchHome() .. "src/" .. _arch_package .. "\""
  debug("Machine:checkAvailability() Executing: " .. cmd)
  --local res, err = io.popen(cmd)
  local res = os.execute(cmd)
  if (res == 0) then 
    info("Machine:checkAvailability() Machine is accessible -> " .. self:toString())
    self.ok = true
  else
    local msg = "Machine:checkAvailability() Machine is unaccessible -> " .. self:toString()
    warn(msg)
--    error(msg):x
  end
  return self.ok
end

function Machine:createSSH()
  --return "echo \"" .. self.pass .. "\" | ssh ".. self.user .. "@" .. self.host .. " -p " .. self.port 
  return "sshpass -p '" .. self.pass .. "' ssh ".. self.user .. "@" .. self.host .. " -p " .. self.port 
end

function Machine:goToArchHome() return "cd " .. self:getArchHome() end
function Machine:getArchHome() return "$\{ARCH_HOME\}" end

function Machine:toString()
  return "host: " .. self.host .. "\tport: " .. self.port .. "\tuser: " .. self.user .. "\tpass: " .. self.pass .. "\tisLocalhost: " .. booleanString(self:isLocalhost()) 
end

function Machine:startDeployer()
  --local cmd = self:createSSH() .. " \"" .. self:goToArchHome() .. "src/" .. _arch_package .. " && sh " .. self:getArchHome() .. "src/" .. _arch_package .. "run.sh & sleep 3\""
  --local cmd = self:createSSH() .. " \"" .. self:goToArchHome() .. "src/" .. _arch_package .. " && sh run.sh & sleep 3\""
  --local cmd = self:createSSH() .. " \"" .. self:goToArchHome() .. "src/" .. _arch_package .. " && sh " .. self:getArchHome() .. "/src/" .. _arch_package .. "run.sh\""
  --local cmd = self:createSSH() .. " \"" .. self:goToArchHome() .. "src/" .. _arch_package .. " && pwd && sh run.sh\""
  local cmd = self:createSSH() .. " \"" .. self:goToArchHome() .. "src/" .. _arch_package .. " && sh " .. self:getArchHome() .. "src/" .. _arch_package .. "run.sh \" &"
  --local cmd = "sshpass -p 'tomzis' ssh airton@192.168.58.132 -p 22 \"cd $ARCH_HOME/src/scs/core/arch/ && sh $ARCH_HOME/src/scs/core/arch/run.sh\""
  debug("Machine:startDeployer() Executing: " .. cmd)
  --debug("Executing: " .. cmd)
  --local res = os.execute(cmd)
  local res = os.execute(cmd)

  debug("Machine:startDeployer() Sleeping for " .. SLEEP_PERIOD .. " seconds")
  os.execute("sleep " .. SLEEP_PERIOD)

  if (res) then
    info("Machine:startDeployer() run.sh was invoked and Deployer is expected to be now running on machine -> " .. self:toString())
    return true
  else
    local msg = "Deployer cannot run on machine -> " .. self:toString()
    return false
  end
end

return Machine

