#!/bin/bash

# NFT Monitor

# USER CONFIG SECTION ==========================================================================
email="example@gmail.com"
wallet_id="10"
# END USER CONFIG ==============================================================================


# ------------------------------------------------------------------------
# All configuration settings should be changed ABOVE, not below this line.
# ------------------------------------------------------------------------
appdir=`pwd`

# Activate Chia python environment
cd ~/chia-blockchain
. ./activate
cd $appdir

# Default starting values
lastnftcount=0
nftcount=0
nfturis=""
newuris=""

# Create a history file if it doesn't exist
if [ -f $appdir/.nfturis ]; then
    history_exists="true"
else
    history_exists="false"
fi

if [ $history_exists == "false" ]; then
    touch $appdir/.nfturis
fi

# Calculate the current number of NFTs in the wallet specified in the USER CONFIG SECTION
nftcount=`chia wallet nft list -i $wallet_id | grep "NFT identifier" | wc -l`

# Gather all the URIs for the data
nfturis=$(chia rpc wallet nft_get_nfts '{"wallet_id": '\"$wallet_id\"'}' | jq '.nft_list[].data_uris[0]' | cut --fields 2 --delimiter=\")
printf "$nfturis\n" > $appdir/.currenturis
grep -Fxvf $appdir/.nfturis $appdir/.currenturis > $appdir/.newuris
rm $appdir/.currenturis

# If history file exists pull the current value
if test -f "$appdir/.nftcount"; then
    lastnftcount=`cat $appdir/.nftcount`
fi

( while read url; do echo "<a href='$url'><img src='$url' width='100px' height='100px'</a>"; done < $appdir/.newuris ) > $appdir/.newurls.html
newuris=`cat $appdir/.newurls.html`

# Send email if the current number of NFTs is different from the value in our history file.
email_template="From: $email\r\nDate: $(date)\r\nSubject: New NFT in Wallet\r\nMIME-Version: 1.0\r\nContent-Type: text/html; charset=utf-8\r\n\r\n<h3>Congratulations! You have a new NFT in your wallet.</h3><br>$newuris\n"
if [ "$nftcount" != "$lastnftcount" ]; then
    printf "$email_template" | /usr/sbin/ssmtp $email
fi

# Update out history files so they are ready for the next time the script runs.
echo $nftcount > $appdir/.nftcount
printf "$nfturis\n" > $appdir/.nfturis

# Clean up temp files
rm $appdir/.newuris
rm $appdir/.newurls.html


# Version History
#
# v0.1.0 - Initial Release:
#            - Basic functionality. 
#            - Email notification for any new NFTs since the last time the script ran.
#            - Included hyperlinked images of the new NFTs.
#            - Instructions on installing and setting up ssmtp with a Gmail account.
#
# v0.1.1 - Changes:
#            - Correction to default values.
#
# v0.1.2 - Changes:
#            - Updated the wallet_id in the NFT count line to not be hardcoded and use user config value.
#
# v0.1.3 - Changes:
#            - Replaced "./" path notation with "$appdir" variable.
#
# v0.2.0 - Changes:
#            - Changed the appdir to be based on pwd command instead of the dirname command. dirname was causing files
#              to be created in the ~/chia-blockchain directory.
#
# v0.2.1 - Changes:
#            - Changed from 'echo' to 'printf' for writing out the uris so the file ends up with one URL per line.
#                echo was wasn't putting each URL on a newline which caused the email to send all NFTs not just new ones.
