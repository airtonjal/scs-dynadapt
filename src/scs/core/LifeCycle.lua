--[[
  _     ___ _____ _____       ______   ______ _     _____ 
 | |   |_ _|  ___| ____|     / ___\ \ / / ___| |   | ____|
 | |    | || |_  |  _|      | |    \ V | |   | |   |  _|  
 | |___ | ||  _| | |___     | |___  | || |___| |___| |___ 
 |_____|___|_|   |_____|     \____| |_| \____|_____|_____|
                                                          
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

local MODULE = "scs.core.LifeCycle"

local DEBUG = VERBOSE.DEBUG
--DEBUG = false
local WARN  = VERBOSE.WARN
local INFO  = VERBOSE.INFO
local DEBUG_PREFIX = "[" .. MODULE .. "] "
local debug   = function (str) if (DEBUG) then print("[ DEBUG ] " .. DEBUG_PREFIX .. str) end end
local warn    = function (str) if (WARN)  then print("[ WARN  ] " .. DEBUG_PREFIX .. str) end end
local info    = function (str) if (INFO)  then print("[ INFO  ] " .. DEBUG_PREFIX .. str) end end
local foutput = function (str) if (DEBUG) then print(str)                 end end
local jump  = function () foutput("\n___________________________________________________________________________________________________________________________________") end
local jumpU = function () foutput("\n¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯") end

local ip = getIP()

-- If we stored a broker instance previously, use it. If not, use the default broker
local oil = oil
if (not oil.orb) then
  debug("Initializing broker on LifeCycle.lua\tIP: " .. ip .. "\tPort: " .. DEFAULT_ORB_PORT)
  oil.orb = oil.init{host = ip, port = DEFAULT_ORB_PORT, flavor = "cooperative;corba.intercepted"}
end
local _orb = oil.orb

--------------------------------------------------------------

module (MODULE)

--------------------------------------------------------------

local LifeCycle = oo.class {

  utils = utils.Utils,

  states = {
    resumed   = "RESUMED",
    halted    = "HALTED",
    suspended = "SUSPENDED"
  },

  OIL_SLEEP = 0.2

}

function LifeCycle:__init()
  local self = oo.rawnew(self, {})

  -- Enqueued requests for suspended components
  self.requestsQueue = {}

  -- Incoming calls
  self.incomingCalls = 0

  -- Calls made by the component
  self.outgoingCalls = 0

  -- Component state
  self.state = self.states.resumed

  return self
end

--
-- Description: changes the state of a component. Facet implementation
-- Parameter state: The new state, defined on the lifecycle idl
--
function LifeCycle:changeState(state)
  local name = tostring(self.context._componentId.name)
  warn("[" .. name .. "] LifeCycle:changeState(state) INVOKED with state\\current " .. state .. "\\" .. self.state )
  if     (state == self.state)            then return true end
  if     (state == self.states.resumed)   then self:dispatchRequestsQueue()
  elseif (state == self.states.halted)    then self:dropPendingRequests()
-- Could not think of anything to do when suspending but to change the state name
--  elseif (state == self.states.suspended) then end
  end
  self.state = state
  warn("[" .. name .. "] LifeCycle:changeState(state) RETURNING state\\current " .. state .. "\\" .. self.state )
  return true
end

--
-- Description: Removes tasks from the OiL scheduler and empties requests queue
--
function LifeCycle:dropPendingRequests()
  -- Removes tasks from the scheduler and empties requests queue
  for _, oilTask in ipairs(self.requestsQueue) do oilTask:remove() end
  self.requestsQueue = {}
  self.incomingCalls = 0
end

--
-- Description: Dispatches the enqueued calls
--
function LifeCycle:dispatchRequestsQueue()
  local name = tostring(self.context._componentId.name)
  info("[" .. name .. "] LifeCycle:dispatchRequestsQueue()   Dispatching queue of size " .. tostring(#self.requestsQueue))
  while(#self.requestsQueue > 0) do
    local oilTask = table.remove(self.requestsQueue, 1)
    oil.tasks:resume(oilTask)
  end
end

--
-- Description: Gets the component state. Facet implementation
--
function LifeCycle:getState() return self.state end

function LifeCycle:toString()
  return "State: " .. self.state .. "\tNumber of requests on queue: " .. #self.requestsQueue .. "\tIncoming calls: " .. self.incomingCalls .. "\tOutgoing calls: " .. self.outgoingCalls
end

--
-- Description: Sleeps the current OiL thread until the component reaches a state considered safe
--
function LifeCycle:reachSafeState() 
  local name = tostring(self.context._componentId.name)
  info("[" .. name .. "] LifeCycle:dispatchRequestsQueue()   Waiting to reach safe state")
  repeat 
    oil.sleep(self.OIL_SLEEP) 
  until (self:isStateSafe()) 
end

--
-- Description: Checks if the component is in a state considered safe for changes
--
function LifeCycle:isStateSafe()
  if (self.incomingCalls == 0 and self.outgoingCalls == 0) then return true else return false end
end

-------------------------------------------------------
-------------------- Interceptors  --------------------
-------------------------------------------------------

--
-- Description: Checks if a given call should be treated by the interceptor or not
-- Parameter call: The request or reply
-- Return: true if the interceptor should treat it, false if it should just forward it
--
local function shouldIntercept(call)
  if not (call or not call.interface_name) then return true end
  local interface_name = call.interface_name
  local scs_int_start = "::scs::core"
  local corba_int_start = "::CORBA"
  if interface_name == LIFECYCLE_INT_NAME then return false end
  -- Should not intercept CORBA nor SCS calls
  if (string.sub(interface_name, 1, string.len(scs_int_start))   == scs_int_start)   then return false end
  if (string.sub(interface_name, 1, string.len(corba_int_start)) == corba_int_start) then return false end
  return true
end

-------------------------------------------------------------
-------------------- Client interceptor  --------------------
-------------------------------------------------------------

--
-- Description: Interceptor method. Intercepts outgoing calls in order to achieve a safe point
-- Parameter request: Described in http://oil.luaforge.net/manual/basics/brokers.html#setserverinterceptor
--
function LifeCycle:sendrequest(request)
  -- Process the request
  --self.processRequest(request)

  --for k, v in ipairs(request.service_context) do output(k, v) end
  local name = tostring(self.context._componentId.name)
  debug("[" .. name .. "] LifeCycle:sendRequest(request)\tState: " .. self.state .. "\tOperation: " .. request.operation_name)
  -- Gets the requested servant
  local servant = request.servant

  -- Checks servant integrity
  --assert(servant ~= nil, "suspension::Suspender::processrequest Servant is nil")

  -- Gets the servant current status
  local status = self.state

  -- Suspends call until resumed
  if (status == self.SUSPENDED) then self:suspendRequest() end

  -- Drops request
  if (status == self.HALTED) then
    request.success = false
  else
    self.outgoingCalls = self.outgoingCalls + 1
  end
  --foutput("\n___________________________________________________________________________________________________________________")
  jump()
end

function LifeCycle:receivereply(reply)
  local name = tostring(self.context._componentId.name) 
  debug("[" .. name .. "] LifeCycle:receiveReply(reply) \tOperation: " .. reply.operation_name .. "\n")
  self.outgoingCalls = self.outgoingCalls - 1
end

--
-- Description: Enqueues and suspends the current thread
--
function LifeCycle:suspendRequest()
  local name = tostring(self.context._componentId.name)
  debug("[" .. name .. "] LifeCycle:suspendRequest() INVOKED\tID: " .. tostring(self.context._componentId.name))
  if (oil.tasks) then
    --if DEBUG then table_print(oil.tasks) end
    local currentThread = oil.tasks.current
    if (currentThread) then
      debug("[" .. name .. "] LifeCycle:suspendRequest() Appending current thread")
      table.insert(self.requestsQueue, currentThread)
      debug("[" .. name .. "] LifeCycle:suspendRequest() Suspending current thread (...) Now requests queue has size " .. tostring(#self.requestsQueue))
      oil.tasks:suspend()
    end
  end
end

-------------------------------------------------------------
-------------------- Server interceptor  --------------------
-------------------------------------------------------------

function LifeCycle:receiverequest(request)
  local name = tostring(self.context._componentId.name)
  debug("[" .. name .. "] LifeCycle:receiveRequest(request) \tState: " .. self.state .. "\tOperation: " .. request.operation_name .. "\tKey:" .. request.object_key)
  if (request.service_context.n > 0) then table_print(request.service_context) end
--  if (type(request.parameters) == "table") then output("Parameters: ") table_print(request.parameters, 1) end

  -- Requests to ILifeCycle interface are never intercepted
  if shouldIntercept(request) then
    debug("[" .. name .. "] LifeCycle:receiverequest(request) Request will be inspected\tState: " .. self.state .. "\tOperation: " .. request.operation_name)
    local status = self.state
    -- Probably throw an exception
    if (status == self.states.halted)  then
      --self:cancelRequest(request) return
      request.success = false
      --request.results = { _orb:newexcept{ "::scs::core::lifecycle::HaltedComponent" , msg = "Component is halted and cannot process request" } }
      request.results = { _orb:newexcept{ "::CORBA::NO_PERMISSION" , minor_code_value = 2 } }
    elseif (status == self.states.suspended) then
      info("[" .. name .. "] LifeCycle:receiverequest(request) STATE IS SUSPENDED!!! GOING TO SUSPEND CALL")
      -- Enqueue call
      self:suspendRequest()
    end
    self.incomingCalls = self.incomingCalls + 1
  end
  --foutput("\n¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\n")
  jumpU()
end

function LifeCycle:sendreply(reply)
  --foutput("\n___________________________________________________________________________________________________________________")
  jump()
  local name = tostring(self.context._componentId.name)
  debug("[" .. name .. "] LifeCycle:sendreply(reply)\tState: " .. self.state .. "\tOperation: " .. reply.operation_name)
  if (not reply.success) then
    warn("[" .. name .. "] LifeCycle:sendreply(reply) Request was not successfull. Exception " .. reply.results[1][1] .. " will be thrown to the client")
    --for k, v in ipairs(reply) do if (type(k) == "string") then debug(k) end end
  else
    debug("[" .. name .. "] LifeCycle:sendreply(reply) Request successfull")
    --for k, v in ipairs (reply.results) do print(k, v) end
    --if (type(reply.results[1]) == "table") then table_print(reply.results[1]) end
    --for k, v in ipairs (reply.results) do print(k, v) end
  end

  --if not (reply.interface_name == LIFECYCLE_INT_NAME) then
  if (shouldIntercept(reply)) then
    self.incomingCalls = self.incomingCalls - 1
  end
  --output(self:toString()) 
  --foutput("\n¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯")
  jumpU()
end

return LifeCycle

