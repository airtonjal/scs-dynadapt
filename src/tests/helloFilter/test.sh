echo "--- TEST.SH ---  Starting ArchManager test  --- TEST.SH ---\n"

ADL="tests.say.adl"
CHANGES="tests.helloFilter.changes"

echo "--- TEST.SH ---  Invoking arch_start.lua  --- TEST.SH ---\n"

lua ../common/arch_start.lua &

sleep 1

echo "\n--- TEST.SH ---  Invoking startup.lua  --- TEST.SH ---\n"

lua ../common/startup.lua

echo "\n--- TEST.SH ---  Invoking add_machine.lua\tAdding for the first time  --- TEST.SH ---\n"

lua ../common/add_machine.lua

echo "\n--- TEST.SH ---  Invoking input_adl.lua\tInputing ADL for the first time  --- TEST.SH ---\n"

lua ../common/input_adl.lua "$ADL"

#echo "\n--- TEST.SH ---  Invoking printArch.lua --- TEST.SH ---\n"

#lua ../common/printArch.lua
echo "\n--- TEST.SH ---  Sleeping for 3 seconds while say runs  --- TEST.SH ---\n"

sleep 3

echo "\n--- TEST.SH ---  Invoking adapt.lua --- TEST.SH ---\n"

lua ../helloFilter/adapt.lua "$CHANGES"

echo "\n--- TEST.SH ---  Sleeping for 3 more seconds for adapted architecture to run  --- TEST.SH ---\n"

sleep 3

echo "\n--- TEST.SH ---  Invoking components_shutdown.lua --- TEST.SH ---\n"

lua ../common/components_shutdown.lua

echo "\n--- TEST.SH --- Invoking deployers_shutdown.lua\tShutting down deployers --- TEST.SH ---\n"

lua ../common/deployers_shutdown.lua

echo "\n--- TEST.SH ---  Invoking arch_shutdown.lua\tShutting down ArchManager  --- TEST.SH ---\n"

lua ../common/arch_shutdown.lua

sleep 1

echo "\n--- TEST.SH ---  Shutting down orb  --- TEST.SH ---\n"

lua ../common/orb_shutdown.lua

echo "\n--- TEST.SH ---  Killing lua processes  --- TEST.SH ---\n"

killall lua

