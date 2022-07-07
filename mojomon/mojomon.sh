#!/bin/bash

# Mojo Monitor

# USER CONFIG SECTION ==========================================================================
email="example@gmail.com"
# END USER CONFIG ==============================================================================

# ------------------------------------------------------------------------
# All configuration settings should be changed ABOVE, not below this line.
# ------------------------------------------------------------------------
appdir=`pwd`

bal=0
lastbal=0

# Activate Chia python environment
cd ~/chia-blockchain
. ./activate
cd $appdir

# Create a history file if it doesn't exist
if [ -f $appdir/.walletbalance ]; then
    history_exists="true"
else
    history_exists="false"
fi

if [ $history_exists == "false" ]; then
    touch $appdir/.walletbalance
fi

# Get wallet balance and check to see if it's different from the last balance and send email if so.
bal=`chia wallet show -w standard_wallet | grep '   -Total Balance:' | cut --fields 14 --delimiter=\ `
lastbal=`cat $appdir/.walletbalance`

if [ "$bal" != "$lastbal" ]; then
    echo "$bal" >$appdir/.walletbalance

    # When I was the target of a dust storm, I uncommented the IF statement that verifies the amount is larger than 0.2 XCH before sending an email.
    # I chose 0.2 because it is less than the payout from mining a block if you are in a pool (0.25) but should stop notifcations on dust.

    #if [ "$bal" > "$lastbal + .2" ]; then
        printf "Subject: New Chia Confirmed Balance: now $bal (was $lastbal)\n\nConfirmed Balance: $bal\nOld Balance: $lastbal" | /usr/sbin/ssmtp $email
    #fi
fi


# Version History
#
# v0.1.0 - Initial Release:
#            - Basic functionality. Will send email notification when the wallet balance changes.
#
