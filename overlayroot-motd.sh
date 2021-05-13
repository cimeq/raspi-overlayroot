if grep -qs 'systemd.volatile' /proc/cmdline; then
cat << EOF

==> WARNING: Overlayroot in effect.
None of the changes you make will be preseved after reboot.

To disable overlayroot remove the 'overlayroot' argument
from the kernel commandline.
EOF
fi
