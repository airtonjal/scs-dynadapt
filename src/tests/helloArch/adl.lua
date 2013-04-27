require "utils.HelloUtils"
require "utils.machines"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"

local ARCH_HOME = os.getenv("ARCH_HOME")

--[[
     _    ____   ____ _   _ ___ _____ _____ ____ _____ _   _ ____  _____       ____  _____ _____ ___ _   _ ___ _____ ___ ___  _   _
    / \  |  _ \ / ___| | | |_ _|_   _| ____/ ___|_   _| | | |  _ \| ____|     |  _ \| ____|  ___|_ _| \ | |_ _|_   _|_ _/ _ \| \ | |
   / _ \ | |_) | |   | |_| || |  | | |  _|| |     | | | | | | |_) |  _|       | | | |  _| | |_   | ||  \| || |  | |  | | | | |  \| |
  / ___ \|  _ <| |___|  _  || |  | | | |__| |___  | | | |_| |  _ <| |___      | |_| | |___|  _|  | || |\  || |  | |  | | |_| | |\  |
 /_/   \_\_| \_\\____|_| |_|___| |_| |_____\____| |_|  \___/|_| \_\_____|     |____/|_____|_|   |___|_| \_|___| |_| |___\___/|_| \_|

--]]

helloService = { name = HELLO_FACET_NAME, interface_name = IDL_IHELLO, arity = MANY_TO_ONE }

-- Definig the Hello role
helloRole = {
  provided = { helloService },
  required = {},
  unique_name = "HelloRole"
}

--[[
  ______   ______ _____ _____ __  __       ___ _   _ ____ _____  _    _   _  ____ _____
 / ___\ \ / / ___|_   _| ____|  \/  |     |_ _| \ | / ___|_   _|/ \  | \ | |/ ___| ____|
 \___ \\ V /\___ \ | | |  _| | |\/| |      | ||  \| \___ \ | | / _ \ |  \| | |   |  _|
  ___) || |  ___) || | | |___| |  | |      | || |\  |___) || |/ ___ \| |\  | |___| |___
 |____/ |_| |____/ |_| |_____|_|  |_|     |___|_| \_|____/ |_/_/   \_\_| \_|\____|_____|

--]]

helloInstance = {
  role = helloRole,
  machine = machines.ubuntu2,
  unique_name = "HelloComponent",
  impl = io.open(ARCH_HOME .. "src/tests/helloArch/hello.lua", "r"):read("*a")
}

ADL = {
  -- Name to be placed as the system composite component name
  system_name = "HelloArch",

  -- Template connections
  architecture = { 
    components = { helloRole },
    relationships = {}
  },

  -- System instances
  system = {
    components = { helloInstance },
    connections = {}
  }
}
