#!/bin/bash

# NFT Monitor

# USER CONFIG SECTION ==========================================================================
email="example@gmail.com"
wallet_id="10"
# END USER CONFIG ==============================================================================


# ------------------------------------------------------------------------
# All configuration settings should be changed ABOVE, not below this line.
# ------------------------------------------------------------------------
appdir=`dirname $0`

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
nftcount=`chia wallet nft list -i 10 | grep "NFT identifier" | wc -l`

# Gather all the URIs for the data
nfturis=$(chia rpc wallet nft_get_nfts '{"wallet_id": '\"$wallet_id\"'}' | jq '.nft_list[].data_uris[0]' | cut --fields 2 --delimiter=\")
printf "$nfturis\n" > $appdir/.currenturis
grep -Fxvf $appdir/.nfturis $appdir/.currenturis > $appdir/.newuris
rm $appdir/.currenturis

# If history file exists pull the current value
if test -f "./.nftcount"; then
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
echo $nfturis > $appdir/.nfturis

# Clean up temp files
rm $appdir/.newuris
rm $appdir/.newurls.html
