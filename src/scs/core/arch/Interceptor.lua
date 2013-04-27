--[[
  ___ _   _ _____ _____ ____   ____ _____ ____ _____ ___  ____       _____ ___  ______        ___    ____  ____  _____ ____  
 |_ _| \ | |_   _| ____|  _ \ / ___| ____|  _ \_   _/ _ \|  _ \     |  ___/ _ \|  _ \ \      / / \  |  _ \|  _ \| ____|  _ \ 
  | ||  \| | | | |  _| | |_) | |   |  _| | |_) || || | | | |_) |    | |_ | | | | |_) \ \ /\ / / _ \ | |_) | | | |  _| | |_) |
  | || |\  | | | | |___|  _ <| |___| |___|  __/ | || |_| |  _ <     |  _|| |_| |  _ < \ V  V / ___ \|  _ <| |_| | |___|  _ < 
 |___|_| \_| |_| |_____|_| \_\\____|_____|_|    |_| \___/|_| \_\    |_|   \___/|_| \_\ \_/\_/_/   \_\_| \_\____/|_____|_| \_\
                                                                                                                             
--]]

local oo          = require "loop.base"
local utils       = require "scs.core.utils"

require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"

local tostring      = tostring
local table_print   = table_print
local getIP         = getIP
local module        = module
local assert        = assert
local output         = print
local pairs         = pairs
local print         = print
local table         = table
local setmetatable  = setmetatable
local ipairs        = ipairs
local os            = os
local type          = type
local string        = string
local table         = table

-- Importing interface definitions
local ILIFECYCLE_NAME    = ILIFECYCLE_NAME
local LIFECYCLE_IDL_NAME = LIFECYCLE_IDL_NAME
local IDL_LIFECYCLE      = IDL_LIFECYCLE
local LIFECYCLE_INT_NAME = LIFECYCLE_INT_NAME

local MODULE = "scs.core.arch.Interceptor"

local DEBUG = VERBOSE.DEBUG
DEBUG = false
local WARN  = VERBOSE.WARN
local INFO  = VERBOSE.INFO
local DEBUG_PREFIX = "[" .. MODULE .. "] "
local debug   = function (str) if (DEBUG) then print("[ DEBUG ] " .. DEBUG_PREFIX .. str) end end
local warn    = function (str) if (WARN)  then print("[ WARN  ] " .. DEBUG_PREFIX .. str) end end
local info    = function (str) if (INFO)  then print("[ INFO  ] " .. DEBUG_PREFIX .. str) end end
local foutput = function (str) if (DEBUG) then print(str)                 end end

local ip = getIP()

-- If we stored a broker instance previously, use it. If not, use the default broker
local _orb = getORB(oil)

--------------------------------------------------------------

module (MODULE)

--------------------------------------------------------------

local Interceptor = oo.class {

  utils = utils.Utils,

  states = {
    resumed   = "RESUMED",
    halted    = "HALTED",
    suspended = "SUSPENDED"
  },

  controlOps = {
    _interface     = true,
    _component     = true,
    _is_a          = true,
    _non_existent  = true,
    _is_equivalent = true
  },


  OIL_SLEEP = 0.2

}

function Interceptor:__init()
  local self = oo.rawnew(self, {})

  -- Table used to forward interceptions to specific components on the same memory space
  self.serverForwards = {}
  self.clientForwards = {}

  return self
end

--
-- Description: Checks if a given call should be treated by the interceptor or not
-- Parameter call: The request or reply
-- Return: true if the interceptor should treat it, false if it should just forward it
--
function Interceptor:shouldIntercept(call)
  if not (call and call.interface_name) then return true end
  local interface_name = call.interface_name
  return not self:isControl(interface_name)
end

--
-- Description: Checks if a given interface is a control interface, meaning it should never be intercepted
-- Parameter interface_name: The IDL interface name
-- Return: true if the interceptor should not treat it, false otherwise
--
function Interceptor:isControl(interface_name)
  local scs_int_start = "::scs::core"
  local scs_idl_start = "IDL:scs/core"
  local corba_int_start = "::CORBA"
  local corba_idl_start = "IDL:CORBA"
  if interface_name == LIFECYCLE_INT_NAME then return true end
  -- Should not intercept CORBA nor SCS calls
  if (string.sub(interface_name, 1, string.len(scs_int_start))   == scs_int_start)   then return true end
  if (string.sub(interface_name, 1, string.len(scs_idl_start))   == scs_idl_start)   then return true end
  if (string.sub(interface_name, 1, string.len(corba_int_start)) == corba_int_start) then return true end
  if (string.sub(interface_name, 1, string.len(corba_idl_start)) == corba_idl_start) then return true end
  return false
end

function Interceptor:registerServerForwarder(key, lifecycle)
  info("Interceptor:registerServerForwarder(key, lifecycle)  Registering server forwarder with key " .. key .. " and lifecycle " .. tostring(lifecycle))
  self.serverForwards[key] = lifecycle
end

function Interceptor:registerClientForwarder(key, lifecycle)
  info("Interceptor:registerClientForwarder(key, lifecycle)  Registering client forwarder with key " .. key .. " and lifecycle " .. tostring(lifecycle))
  self.clientForwards[key] = lifecycle
end

function Interceptor:unregisterServerForwarder(key)
  info("Interceptor:unregisterServerForwarder(key)  Unregistering server forwarder with key " .. key)
  self.serverForwards[key] = nil
end

function Interceptor:unregisterClientForwarder(key)
  info("Interceptor:unregisterClientForwarder(key)  Unregistering client forwarder with key " .. key)
  self.clientForwards[key] = nil
end


-------------------------------------------------------------
-------------------- Client interceptor  --------------------
-------------------------------------------------------------

--
-- Description: Interceptor method. Intercepts outgoing calls in order to achieve a safe point
-- Parameter request: Described in http://oil.luaforge.net/manual/basics/brokers.html#setserverinterceptor
--
function Interceptor:sendrequest(request)
  debug("[Client] Interceptor:sendRequest(request)\tOperation: " .. request.operation_name .. "\tKey: " .. request.object_key) 
  if (self:shouldIntercept(request)) then
    local life = self.clientForwards[request.object_key]
    if (life and life.sendrequest) then
      life:sendrequest(request)
    else
      info("[Client] LifeCycle not found for key " .. request.object_key)
    end
  end
end

function Interceptor:receivereply(reply)
  debug("[Client] Interceptor:receiveReply(reply)\tOperation: " .. reply.operation_name .. "\tKey: " .. reply.object_key)
  if (self:shouldIntercept(reply)) then
    local life = self.clientForwards[reply.object_key]
    if (life and life.receivereply) then
      life:receivereply(reply)
    else
      info("[Client] LifeCycle not found for key " .. reply.object_key)
    end
  end
end
-------------------------------------------------------------
-------------------- Server interceptor  --------------------
-------------------------------------------------------------

function Interceptor:receiverequest(request)
  debug("[Server] Interceptor:receiveRequest(request)\tOperation: " .. request.operation_name .. "\tKey: " .. request.object_key)  
  if (self:isControl(request.operation_name)) then return end
  if (self:shouldIntercept(request)) then
    local life = self.serverForwards[request.object_key]
    if (life and life.receiverequest) then
      life:receiverequest(request)
    else
      info("[Server] LifeCycle not found for key " .. request.object_key)
    end
  end
end

function Interceptor:sendreply(reply)
  debug("[Server] Interceptor:sendReply(reply)\tOperation: " .. reply.operation_name .. "\tKey: " .. reply.object_key)  
  if (self:isControl(reply.operation_name)) then return end
  if (self:shouldIntercept(reply)) then
    local life = self.serverForwards[reply.object_key]
    if (life and life.sendreply) then
      life:sendreply(reply)
    else
      info("[Server] LifeCycle not found for key " .. reply.object_key)
    end
  end
end

function Interceptor:isControl(operation_name)
  if (Interceptor.controlOps[operation_name]) then
    return true
  else
    return false
  end
end


return Interceptor

