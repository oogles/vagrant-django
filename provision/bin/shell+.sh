SCRIPT_PATH="bin/shell+"

if [ -f "$SCRIPT_PATH" ]; then
	exit
fi

cat <<EOF >> "$SCRIPT_PATH"
/vagrant/manage.py shell_plus
EOF

chown vagrant:vagrant "$SCRIPT_PATH"
chmod u+x "$SCRIPT_PATH"
