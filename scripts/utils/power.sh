#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"

terminate_clients() {
  	TIMEOUT=5
	
	client_pids=$(hyprctl clients -j | jq -r '.[] | .pid')

	
	for pid in $client_pids; do
		hyprlab message info ":: Sending SIGTERM to PID $pid"
		kill -15 $pid
	done

	start_time=$(date +%s)
	for pid in $client_pids; do
		
		while kill -0 $pid 2>/dev/null; do
		current_time=$(date +%s)
		elapsed_time=$((current_time - start_time))

		if [ $elapsed_time -ge $TIMEOUT ]; then
			echo ":: Timeout reached."
			return 0
		fi

		echo ":: Waiting for PID $pid to terminate..."
		sleep 1
		done

		hyprlab message ok ":: PID $pid has terminated."
	done
}


goExit() {
	echo ":: Exit"
	terminate_clients
	sleep 0.5
	hyprctl dispatch exit
	sleep 2
}

goLock() {
	echo ":: Lock"
	hyprlab notify normal Hyprlab Hyprlab "Locking ..." -i preferences-system
	sleep 0.5
	hyprlock
	hyprlab notify normal Hyprlab Hyperlab "Welcome Back" -i hand
}

goReboot() {
	echo ":: Reboot"
	hyprlab notify normal Hyprlab Hyprlab "Rebooting ..." -i preferences-system
	terminate_clients
	sleep 0.5
	systemctl reboot
}

goShutdown() {
	echo ":: Shutdown"
	hyprlab notify normal Hyprlab Hyprlab "Shutting down ..." -i preferences-system
	terminate_clients
	sleep 0.5
	systemctl poweroff
}

goSuspend() {
	echo ":: Suspend"
	hyprlab notify normal Hyprlab Hyprlab "Suspending ..." -i preferences-system
	sleep 0.5
	systemctl suspend
}

goHibernate() {
	echo ":: Hibernate"
	hyprlab notify normal Hyprlab Hyprlab "Hibernating ..." -i preferences-system
	sleep 1
	systemctl hibernate
}

help() {
cat <<EOF
Usage:
  $(basename $0) <command>

Commands :
	lock		-> Lock (hyprlock)
	shutdown	-> Shutdown
	suspend		-> Suspend
	hibernate	-> Hibernate
	reboot		-> Reboot
	exit		-> Exit hyprland
	-h, --help	-> Show this message
EOF
}

case $1 in 
	lock) goLock;;
	shutdown) goShutdown;;
	suspend) goSuspend;;
	hibernate) goHibernate;;
	reboot) goReboot;;
	exit) goExit;;
	""|-h|--help)help && exit 0;;
	*) hyprlab message fail "Unknown options : $1" && help
	exit 1;;
esac
