#!/bin/sh

#this code lists enlistments that have an associated SDCLIENT

#try calling listEnlistments, silencing any errors
NEW_ENLISTMENT_NAMES=$(listEnlistments 2>/dev/null);
echo $NEW_ENLISTMENT_NAMES;

if test "$NEW_ENLISTMENT_NAMES" != ""; then
	#echo "new setup, trying to get all enlistments";
echo Helloworld2;
	PLISTER=/Library/Frameworks/Abracode.framework/Support/plister;
	ENLISTMENT_PLIST="/Users/$USER/.enlistments.plist";
	ENLISTMENT_ARRAY=( $NEW_ENLISTMENT_NAMES );
	for ONE_ENLISTMENT in "${ENLISTMENT_ARRAY[@]}"
	do
		ONE_CLIENT=$("$PLISTER" get string "$ENLISTMENT_PLIST" "/$ONE_ENLISTMENT/SDCLIENT");
		if test "$ONE_CLIENT" ; then
			echo "$ONE_ENLISTMENT";
		fi;
	done
	exit 0;
fi;

#old setup, SDCLIENT is the enlistment
echo "$SDCLIENT";
