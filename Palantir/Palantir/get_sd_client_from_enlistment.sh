#!/bin/sh

#this code obtains SDCLIENT associated with enlistment

#try calling listEnlistments, silencing any errors
NEW_ENLISTMENT_NAMES=$(listEnlistments 2>/dev/null);

if test "$NEW_ENLISTMENT_NAMES" != ""; then
	ENLISTMENT_NAME=$1;
	#echo "new setup, trying to get all enlistments";
	PLISTER=/Library/Frameworks/Abracode.framework/Support/plister;
	ENLISTMENT_PLIST="/Users/$USER/.enlistments.plist";
	ENLISTMENT_CLIENT=$("$PLISTER" get string "$ENLISTMENT_PLIST" "/$ENLISTMENT_NAME/SDCLIENT");
	if test -n "$ENLISTMENT_CLIENT" ; then
		echo "$ENLISTMENT_CLIENT";
		exit 0;
	fi;
fi;

#old setup, SDCLIENT is the enlistment
echo "$SDCLIENT";
