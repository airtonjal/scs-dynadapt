require "utils.machines"
require "tests.say.adl"

-- Definig the new role, Filter
FilterRole = {
  provided = { HelloService },
  required = { HelloService },
  unique_name = "FilterRole"
}

HelloFilterRelationship = {
  client   = FilterRole,
  server   = HelloRole,
  service  = HelloService,
  unique_name = "HelloFilterRelationship"
}

SayFilterRelationship = {
  client   = SayRole,
  server   = FilterRole,
  service  = HelloService,
  unique_name = "SayFilterRelationship"
}

FilterInstance = {
  role        = FilterRole,
  machine     = machines.ubuntu2,
  unique_name = "FilterComponent",
  impl        = io.open(ARCH_HOME .. "src/tests/helloFilter/filter.lua", "r"):read("*a")
}

HelloFilterConnection = {
  clients = { FilterInstance },
  servers = { HelloInstance },
  relationship = HelloFilterRelationship,
  unique_name = "HelloFilterConnection"
}

SayFilterConnection = {
  clients = { SayInstance },
  servers = { FilterInstance },
  relationship = SayFilterRelationship,
  unique_name = "SayFilterConnection"
}

adaptation = {
  architectureChange = {
    newRoles = { FilterRole },
    removed = { HelloRelationship },
    added   = { HelloFilterRelationship, SayFilterRelationship },
  },
  systemChange = {
    componentChanges = { },
    newComponents = { FilterInstance },
    removed = { HelloConnection },
    added   = { HelloFilterConnection, SayFilterConnection }
  }
}
