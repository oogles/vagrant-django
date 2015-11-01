SCRIPT_PATH="bin/runserver+"

if [ -f "$SCRIPT_PATH" ]; then
	exit
fi

cat <<EOF >> "$SCRIPT_PATH"
port=\$1
shift

if [ -z "\$port" ]; then
	echo "No port provided"
	exit 1
fi

args=()
args+="0.0.0.0:\$port"
for i in "\$@"; do
	args+=" \$i"
done

echo "Cleaning .pyc files..."
/vagrant/manage.py clean_pyc

echo "Initiating runserver..."
delay=3
while true; do
	stty echo
	/vagrant/manage.py runserver_plus \${args[@]}
	echo '--------------------------------------------------'
	echo "Runserver crashed/stopped. Restarting in \$delay seconds. Ctrl+C to cancel."
	sleep "\$delay"
done
EOF

chown vagrant:vagrant "$SCRIPT_PATH"
chmod u+x "$SCRIPT_PATH"
