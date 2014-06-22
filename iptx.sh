#!/bin/sh

# iptx - Iptables helper for your laptop
# 2014, Laurent Ghigonis <laurent@gouloum.fr>

PROGRAM="$(basename $0)"
CONF_FILE="$HOME/.iptx.conf"

write_default_conf() {
	cat > $CONF_FILE <<-_EOF
# Also add you own services to /etc/services.local

# IF_WIRE: default Ethernet interface
IF_WIRE="eth0"
# IF_WIFI: default WIFI interface
IF_WIFI="wlan0"

# HAS_LOGDROP handles an existing logdrop rules.
# It supposes you to have the following iptables rules already:
# iptables -N LOGDROP
# iptables -A LOGDROP -m limit --limit 3/sec -j LOG --log-prefix "iptables-drop: " --log-level 4
# iptables -A LOGDROP -j DROP
HAS_LOGDROP=0

# LOG_CONNECTIONS adds a LOG rule for each ACCEPT rule added
LOG_CONNECTIONS=0
	_EOF
}

fatal_usage() {
	cat <<-_EOF
	Usage: $PROGRAM (clean | show | <service> | port/proto) [<interface>] [open | close]

	Examples:
	$PROGRAM ftp                    # Open ftp port on ethernet interface
	$PROGRAM ftp close              # Close ftp port on ethernet interface
	$PROGRAM http                   # Open http port on ethernet interface
	$PROGRAM http wifi              # Open http port on wireless interface
	$PROGRAM http all close         # Close http port on both interfaces
	$PROGRAM 12345/tcp eth3         # Open 12345/tcp on eth3
	$PROGRAM 12345/tcp eth3 close   # Close 12345/tcp on eth3
	$PROGRAM clean                  # Restore iptables defaults
	_EOF

	exit 1
}

trace() {
	echo "[-] $@"
	eval $@
}

ipt_rule() {
	port=$(echo $1 |cut -d'/' -f1)
	proto=$(echo $1 |cut -d'/' -f2)
	if [ $iface == "all" ]; then
		iface=$IF_WIRE; ipt_rule $proto $port
		iface=$IF_WIFI; ipt_rule $proto $port
		return
	fi
	TARGET_ACCEPT='-j ACCEPT'
	TARGET_LOG='-j LOG --log-prefix "iptables-accept: " --log-level 4'
	rule="INPUT -i $iface -p $proto -m $proto --dport $port -m limit --limit 5/sec $log -m state --state NEW"
	if [ $action == "open" ]; then
		[ $HAS_LOGDROP -eq 1 ] && trace sudo iptables -D INPUT -j LOGDROP
		[ $LOG_CONNECTIONS -eq 1 ] && trace sudo iptables -A $rule $TARGET_LOG
		trace sudo iptables -A $rule $TARGET_ACCEPT
		[ $HAS_LOGDROP -eq 1 ] && trace sudo iptables -A INPUT -j LOGDROP
	elif [ $action == "close" ]; then
		trace sudo iptables -D $rule $TARGET_ACCEPT
		[ $LOG_CONNECTIONS -eq 1 ] && trace sudo iptables -D $rule $TARGET_LOG
	fi
}

ipt_clean() {
	trace sudo /etc/init.d/iptables reload
}

ipt_show() {
	trace sudo iptables -nvL
}

[ ! -e $CONF_FILE ] && write_default_conf
source $CONF_FILE
[ $# -lt 1 -o $# -gt 3 -o "$1" == "-h" ] && fatal_usage
cmd=$1
iface=$IF_WIRE
action="open"
if [ $# -gt 1 ]; then
	if [ $2 == "open" -o $2 == "close" ]; then
		action=$2
	else
		iface=$2
		[ $# -gt 2 ] && action=$3
	fi
fi
[ $iface == "wire" ] && iface=$IF_WIRE
[ $iface == "wifi" ] && iface=$IF_WIFI

case $cmd in
	# Commands
	clean) ipt_clean; ipt_show;;
	show) ipt_show;;
	*)
		# Service name OR port/proto
		service=$(egrep "^$cmd[[:blank:]]" /etc/services 2>/dev/null |head -n1 |awk '{print $2}')
		[ "$service" == "" ] && service=$(egrep "^$cmd[[:blank:]]" /etc/services.local 2>/dev/null |head -n1 |awk '{print $2}')
		[ "$service" == "" ] && service=$(echo $cmd |grep "/")
		[ "$service" == "" ] && echo "Cannot recognize service name or port/proto" && exit 1
		ipt_rule $service
		;;
esac
