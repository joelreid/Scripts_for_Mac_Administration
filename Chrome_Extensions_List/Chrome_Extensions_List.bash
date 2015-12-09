#!/bin/bash

# List_Chrome_Extensions.bash

# Copyright (c) Joel Reid 2015
# Distributed under the MIT License (terms at http://opensource.org/licenses/MIT)
# https://github.com/joelreid
# adapted from script by jrwilcox:
# https://jamfnation.jamfsoftware.com/discussion.html?id=11307#responseChild86288


# config _________________________________________________

# "no" for stdout, "yes" to add Extension Attribute tags. (string! no bools in bash)
casperEA="no";
# script lists exts of all users except these. (a single string, space delimited)
skipUsers="alice bob liz.smith guest";


# functions ______________________________________________

# wow
function jsonval {
    temp=`echo $json | sed -e 's/\\\\\//\//g' -e 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed -e 's/\"\:\"/\|/g' -e 's/\]//' -e 's/[\,]/ /g' -e 's/\"//g' | grep -w $property | tail -1`
    echo ${temp##*|}
}

# list one user's extensions
function getuserextensions {
    cd "/Users/${thisUser}/Library/Application Support/Google/Chrome/Default/Extensions"
    for d in *; do
        JSONS=$( find "/Users/${thisUser}/Library/Application Support/Google/Chrome/Default/Extensions/$d" -maxdepth 3 -name "manifest.json" )
        while read JSON; do
            NAME=$( awk -F'"' '/"name"/{print $4}' "$JSON" )
        done < <(echo "$JSONS")
        if [[ "$NAME" =~ "_MSG_" ]]; then
            property=$(echo $NAME | sed -e "s/__MSG_//" -e "s/__//" )
            myPath=$(echo $JSONS | sed "s:manifest.json:_locales/en_US/messages.json:" )
            if [ ! -f "$myPath" ]; then
                myPath=$(echo $JSONS | sed "s:manifest.json:_locales/en/messages.json:" )
            fi
            json=$(cat "$myPath" | sed '/description/d')
            NAME=$(jsonval | sed 's/.*://' )
            if [ -z "$NAME" ]; then
                property=$(echo "-i $property")
                NAME=$(jsonval | sed 's/.*://' )
            fi
        fi
        if [ "${#d}" -eq 32 ];then
            EXTS+=( "${thisUser} • ${NAME} • ${d} __\n" )
        fi
    done
}


# main __________________________________________________

# populate the list of user accounts to walk, strip in-built os users
userList="$(dscl . list /Users uid | awk '$2 >= 100 && $0 !~ /^_/ {print $1}')";
for thisUser in $userList; do
	# make sure we're not testing an exempt user (populated in #config)
	for skipTest in ${skipUsers}; do
		if [ $thisUser = $skipTest ]; then thisUser="skip"; fi
	done
	if [ $thisUser = "skip" ]; then
		result+="${thisUser} • In exempt users list __"$'\n';
		continue;
	fi
	if [ ! -d "/Users/${thisUser}/Library/Application Support/Google/Chrome/Default/Extensions" ]; then
		result+="${thisUser} • No Extensions Found __"$'\n';
		continue;
	fi
	getuserextensions
done

if [ "$casperEA" = "yes" ]; then echo "<result>"; fi
echo "User • Chrome Extension • Extension ID __";
echo -e "${EXTS[@]}" | sed -e 's/^[ \t]*//' -e '/^$/d' -e 's/  / /' | sort ;
if [ "$casperEA" = "yes" ]; then echo "</result>"; fi
exit 0;
