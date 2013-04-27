require "utils.machines"

ADL = {
  -- Name to be placed as the system composite component name
  system_name = "test",

  architecture = { relationships = {}, components = {} },

  -- Template connections
  system = {
--    firstConnection = {
--      clients = {
--        --service = { name = "IRecord", interface_name = "IDL:scs/core/IRecord:1.0" },
--      },
--      servers = {
--      },
--      connection = {
--      }
--    }
    connections = {},
    components = {}
  },
}
