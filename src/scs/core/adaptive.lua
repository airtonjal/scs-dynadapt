local scs         = require "scs.core.base"
local utils       = require "scs.core.utils"
local composite   = require "scs.core.composite"
local oo          = require "loop.base"
local LifeCycle   = require "scs.core.LifeCycle"
local Interceptor = require "scs.core.arch.Interceptor"

require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"

local table_print   = table_print
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

-- Importing interface definitions
require "scs.core.arch.utils.ArchUtils"

local IDL_IMETA          = IDL_IMETA
local IDL_ICOMPONENT     = IDL_ICOMPONENT
local ILIFECYCLE_NAME    = ILIFECYCLE_NAME 
local IDL_LIFECYCLE      = IDL_LIFECYCLE 
local LIFECYCLE_INT_NAME = LIFECYCLE_INT_NAME

local MODULE = "scs.core.adaptive"

local DEBUG = VERBOSE.DEBUG
--DEBUG = false
local WARN  = VERBOSE.WARN
local INFO  = VERBOSE.INFO

local DEBUG_PREFIX = "[" .. MODULE .. "] "
local debug = function(str) if (DEBUG) then print("[ DEBUG ] " .. DEBUG_PREFIX .. str) end end
local warn  = function(str) if (WARN)  then print("[ WARN  ] " .. DEBUG_PREFIX .. str) end end
local info  = function(str) if (INFO)  then print("[ INFO  ] " .. DEBUG_PREFIX .. str) end end

local ip = getIP()

-- If we stored a broker instance previously, use it. If not, use the default broker
local oil = oil
if (not oil.orb) then 
  debug("Initializing broker on adaptive.lua\tIP: " .. ip .. "Port: " .. DEFAULT_ORB_PORT)
  oil.orb = oil.init{host = ip, port = DEFAULT_ORB_PORT, flavor = "cooperative;corba.intercepted"}
end
local _orb = oil.orb

local interceptor = Interceptor()

--------------------------------------------------------------

module (MODULE)

--------------------------------------------------------------

local function fillAdaptiveComponentDescriptions(facetDescs)
  debug("fillAdaptiveComponentDescriptions(facetDescs) INVOKED")
  if not facetDescs then facetDescs = {} end
  
  local hasLC = false

  for name, desc in pairs(facetDescs) do
    --debug("Adding facet: " .. name)
    if desc.interface_name == IDL_LIFECYCLE then
      warn("fillAdaptiveComponentDescriptions(facetDescs) An implementation of LifeCycle interface was found, will not use default")
      hasLC = true
    end
  end

  if not hasLC then
    -- checks if the name ILifeCycle can be used
    if facetDescs.ILifeCycle then 
      warn("fillAdaptiveComponentDescriptions(facetDescs) ILifeCycle entry was found on facetDescs")
      debug("fillAdaptiveComponentDescriptions(facetDescs) RETURNING true")
      return false
    end
    facetDescs.ILifeCycle                = {}
    facetDescs.ILifeCycle.name           = ILIFECYCLE_NAME
    facetDescs.ILifeCycle.interface_name = IDL_LIFECYCLE
  end
  debug("fillAdaptiveComponentDescriptions(facetDescs) RETURNING true")
  return true
end


function newAdaptiveComponent(facetDescs, receptacleDescs, componentId, isComposite)
  info("newAdaptiveComponent(...) INVOKED\tCreating component with name " .. componentId.name)
  -- Adds ILifeCycle facet description and implementation
  if not fillAdaptiveComponentDescriptions(facetDescs) then
    return nil, "scs.core.adaptive::newAdaptiveComponent:: Cannot fill basic descriptions for ILifeCycle interface" 
  end
  local facetKeys = {}
  for k, v in pairs(facetDescs) do
    if (v.key) and (not interceptor:isControl(v.interface_name)) then      
      debug("newAdaptiveComponent(...) " .. componentId.name .. " component interface " .. v.interface_name .. " with key " .. v.key .. " will be intercepted")
      facetKeys[#facetKeys + 1] = v.key
    else
      debug("newAdaptiveComponent(...) " .. componentId.name .. " component interface " .. v.interface_name .. " will not be intercepted")
    end
  end

  -- Instance here to have the lifecycle reference before-hand
  local lifeCycle = LifeCycle()
  debug("newAdaptiveComponent(...) Starting LifeCycle servant for component " .. componentId.name)
  local lifeCycleKey = componentId.name .. ILIFECYCLE_NAME
  facetDescs.ILifeCycle.facet_ref = _orb:newservant(lifeCycle, lifeCycleKey, IDL_LIFECYCLE)

  local newComponentFunction = nil

  -- Chooses function to instantiate component
  if (isComposite) then 
    debug("newAdaptiveComponent(...) Creating component using composite function")
    newComponentFunction = composite.newCompositeComponent 
  else 
    debug("newAdaptiveComponent(...) Creating component using scs function")
    newComponentFunction = scs.newComponent 
  end
  
  local instance, err = newComponentFunction(facetDescs, receptacleDescs, componentId, _orb)
  if (not instance) then return nil, err end
  local orb = instance._orb
  
  --instance._receptacleDescs.lifeCycle = lifeCycle
  --for k, v in pairs(instance._receptacleDescs) do 
  --  v.lifeCycle = lifeCycle
  --end
  --for k,v in pairs(instance._facetDescs[ILIFECYCLE_NAME]) do print(k,v) end
  instance.lifeCycle = lifeCycle
  instance.interceptor = interceptor

  debug("newAdaptiveComponent(...) Setting LifeCycle client and server interceptors on component " .. componentId.name)
  --orb:setclientinterceptor(lifeCycle)
--  orb:setserverinterceptor(lifeCycle)
  orb:setclientinterceptor(interceptor)
  orb:setserverinterceptor(interceptor)
  -- Registers a forwarder to interceptor calls to components in the same memory space
  for facet, key in ipairs(facetKeys) do
    interceptor:registerServerForwarder(key, lifeCycle)
  end

  debug("newAdaptiveComponent(...) RETURNING")
  return instance
end

