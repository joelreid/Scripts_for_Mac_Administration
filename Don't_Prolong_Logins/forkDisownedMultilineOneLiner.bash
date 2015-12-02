#!/bin/bash

#  forkDisownedMultilineOneLiner.bash
#  Copyright (c) Joel Reid 2015
#  Distributed under the MIT License (terms at http://opensource.org/licenses/MIT)

#  demonstrates one way to get a script to exit instantly, but fork and disown other,
#+ perhaps-long-running, perhaps-buggy code. The forked section will not delay the outer.


# all the logger commands are just to see this demo script work in Console.app, etc
logger "script is started"

# having a block of code in a " ( code ) & disown " is the only magic behind the curtain
(
	# delays are fine
	sleep 3 ;
	logger inner code started;
	# <--embedded comments fine too, apparently
	logger These; 
	# embedded weakly-quoted strings fine
	maths="5 - 2";
	# embedded command substitution fine
	sleep "$( echo "$maths" | bc )";
	logger lines;
	sleep 2;
	logger take;
	sleep 1;
	logger several;
	sleep 1;
	logger seconds;
	sleep 1;
	logger inner code done;
) & disown

logger "script is DONE";

exit 0;

