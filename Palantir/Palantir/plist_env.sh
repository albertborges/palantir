#!/bin/sh

# plist_env: bash script to set environment variables from plist
#
# plist must have a dictionary at root level
# each key and string value in dictionary is exported as one env variable
# you should use "source" to run this script
# that way the script will be executed in the same shell, not child shell
# and environment variables will be in effect for the rest of your script
# e.g. source /path/to/plist_env.sh ~/.MacOSX/environment.plist
#
# OSX 10.8 removed support for ~/.MacOSX/environment.plist in all processes but Terminal
# with this script you can have this functionality back for scripts that need it
#
# For new enlistment type ignore the environment.plist path
# set the variables for the first enlistment available 

# Sorcerer wrapper around sd with error handling and retry on expired ticket
sd()
{
	args=("$@");
	sd_output=$("$MS_TOOLS_ROOT/cli/sd" "${args[@]}" 2>&1);
	sd_result=$?;
	echo "$sd_output";
	if test "$sd_result" -ne 0; then
		#sd returned some error, let's check for expired ticket
		echo "$sd_output" | grep --quiet "Ticket expired";
		is_expired=$?;

		if test $is_expired -eq 0; then
			#destroy the ticket to force GUI authentication and try again
			/usr/bin/kdestroy;
			"$MS_TOOLS_ROOT/cli/sd" "${args[@]}" 2>&1;
		else
			/Library/Frameworks/Abracode.framework/Support/alert --level stop --title "Source Depot Error" "$sd_output";
		fi;
	fi;
}

#try calling listEnlistments, silencing any errors
NEW_ENLISTMENT_NAMES=$(listEnlistments 2>/dev/null);

if test "$NEW_ENLISTMENT_NAMES" != ""; then
	#echo "new setup";
	ENL_NAME="$2";
	if test -n "$ENL_NAME"; then
		changeEnlistment "$ENL_NAME" 1>/dev/null;
	else
		changeEnlistmentIndex 0 1>/dev/null;
	fi;
else
	#echo "old setup";
	ENV_PLIST=$1;
	PLISTER=/Library/Frameworks/Abracode.framework/Support/plister;
	ITEM_COUNT=$("$PLISTER" get count "$ENV_PLIST" /);
	CURR_INDEX=0;
	while [ $CURR_INDEX -lt $ITEM_COUNT ]; do
		ONE_KEY=$("$PLISTER" get key "$ENV_PLIST" /$CURR_INDEX);
		ONE_VAL=$("$PLISTER" get string "$ENV_PLIST" "/$ONE_KEY");
		#echo "export $ONE_KEY=$ONE_VAL";
		export "$ONE_KEY"="$ONE_VAL";
		let CURR_INDEX=CURR_INDEX+1 
	done

	source "$MS_TOOLS_ROOT/cli/sd_launch" "";
fi;

