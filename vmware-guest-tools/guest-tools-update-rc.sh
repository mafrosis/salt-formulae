#! /bin/bash
#
# Liberally adapted from http://vmadmin.nt.com.au/?p=52
# All credit to the original author
#
# Following lines auto-recompile VM Tools when kernel updated
#

# VMToolsCheckFile is created in each kernel dir to prevent patching a kernel twice
VMToolsCheckFile="/lib/modules/$(uname -r)/misc/.vmware_installed"

# Extract the guest tools version
VMToolsVersion=$(vmware-config-tools.pl --help 2>&1 | awk '$0 ~ /^VMware Tools [0-9]/ { print $3,$4 }')

printf "\nCurrent VM Tools version: $VMToolsVersion\n\n"

# Run the vmware script accepting all defaults
if [[ ! -e $VMToolsCheckFile || `grep -c "$VMToolsVersion" $VMToolsCheckFile` -eq 0 ]]; then
	[ -x /usr/bin/vmware-config-tools.pl ] && \
	printf "Automatically compiling new build of VMware Tools\n\n" && \
	/usr/bin/vmware-config-tools.pl --default && \
	printf "$VMToolsVersion" > $VMToolsCheckFile
fi
