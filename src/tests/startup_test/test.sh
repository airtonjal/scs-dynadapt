echo "--- TEST.SH ---  Starting ArchManager test  --- TEST.SH ---\n"

echo "--- TEST.SH ---  Invoking arch_start.lua  --- TEST.SH ---\n"

lua ../common/arch_start.lua &

sleep 1

echo "\n--- TEST.SH ---  Invoking startup.lua  --- TEST.SH ---\n"

lua ../common/startup.lua

echo "\n--- TEST.SH ---  Invoking add_machine.lua\tAdding for the first time  --- TEST.SH ---\n"

lua ../common/add_machine.lua 

echo "\n--- TEST.SH ---  Invoking readd_machine.lua\tMachineAlreadyExists should be caught silently  --- TEST.SH ---\n"

lua ../common/readd_machine.lua /home/airton/scs_dynadapt/src/tests/startup_test/adl #`hostname`

echo "\n--- TEST.SH ---  Invoking input_adl.lua\tInputing ADL for the first time  --- TEST.SH ---\n"

lua ../common/input_adl.lua /home/airton/scs_dynadapt/src/tests/startup_test/adl

echo "\n--- TEST.SH ---  Invoking input_adl.lua\tAlreadyStartedException should be caught silently  --- TEST.SH ---\n"

lua ../common/input_adl.lua /home/airton/scs_dynadapt/src/tests/startup_test/adl

echo "\n--- TEST.SH --- Invoking deployers_shutdown.lua\tShutting down deployers --- TEST.SH ---\n"

lua ../common/deployers_shutdown.lua

echo "\n--- TEST.SH ---  Invoking arch_shutdown.lua\tShutting down ArchManager  --- TEST.SH ---\n"

lua ../common/arch_shutdown.lua

sleep 1

echo "\n--- TEST.SH ---  Shutting down orb  --- TEST.SH ---\n"

lua ../common/orb_shutdown.lua

echo "\n--- TEST.SH ---  Killing lua processes  --- TEST.SH ---\n"

killall lua
