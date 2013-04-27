echo "--- TEST.SH ---  Starting ArchManager test  --- TEST.SH ---\n"

ADL="tests.helloArch.adl"

echo "--- TEST.SH ---  Invoking arch_start.lua  --- TEST.SH ---\n"

lua ../common/arch_start.lua &

sleep 1

echo "\n--- TEST.SH ---  Invoking startup.lua  --- TEST.SH ---\n"

lua ../common/startup.lua 

echo "\n--- TEST.SH ---  Invoking add_machine.lua\tAdding for the first time  --- TEST.SH ---\n"

lua ../common/add_machine.lua

echo "\n--- TEST.SH ---  Invoking input_adl.lua\tInputing ADL for the first time  --- TEST.SH ---\n"

lua ../common/input_adl.lua "$ADL"

echo "\n--- TEST.SH ---  Invoking say_hello.lua with the old Hello implementation --- TEST.SH ---\n"

lua ../helloArch/say_hello.lua

echo "\n--- TEST.SH ---  Invoking replace_hello.lua --- TEST.SH ---\n"

lua replace_hello.lua "$ADL"

echo "\n--- TEST.SH ---  Invoking say_hello.lua with the new Hello implementation --- TEST.SH ---\n"

lua ../helloArch/say_hello.lua

echo "\n--- TEST.SH --- Invoking components_shutdown.lua\tShutting down components from arch --- TEST.SH ---\n"

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

