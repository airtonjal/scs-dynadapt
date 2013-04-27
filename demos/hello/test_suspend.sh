#!/bin/sh

echo "Starting component"
lua hello.lua &
sleep 1

echo "Saying hello 1"
lua hello_say.lua 1

sleep 1

echo "Getting state"
# Firtly prints the state
lua hello_getstate.lua

sleep 1

echo "Suspending component"
lua hello_suspend.lua &

sleep 1

# Tries to use the hello facet, request will be enqueued
echo "Saying hello 2"
lua hello_say.lua 2 &
sleep 1
echo "Saying hello 3"
lua hello_say.lua 3 &
sleep 1
echo "Saying hello 4"
lua hello_say.lua 4 &
sleep 1

echo "Resuming component"
lua hello_resume.lua

killall lua

