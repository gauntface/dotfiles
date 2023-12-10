#!/bin/bash

# TODO: Check this doc for more info: https://wiki.ubuntu.com/Plymouth#Running_Plymouth_.22post-boot.22

sudo plymouthd --debug --debug-file=/home/matt/Projects/Tools/dotfiles/plymouth.debug
sudo plymouth show-splash

sleep 2s

# Wait and display a message and wait again
sudo plymouth display-message --text="Starting event loop in 2s..."
sleep 2s

sudo plymouth display-message --text="Starting event loop..."

for ((I=0;I<5;I++)); do
	sudo plymouth display-message --text="Event update ${I}..."
	sudo plymouth --update=event.$I;
	sleep 1s;
done;

# Pause boot progress and wait for a key press
#plymouth pause-progress
#plymouth message --text="pausing boot - press 'c' or space bar to continue"
#plymouth watch-keystroke --keys="cC " --command="tee /tmp/c_key_pressed"
#plymouth message --text="resuming boot"
#plymouth unpause-progress

sudo plymouth --quit