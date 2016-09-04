#!/bin/sh

URLS=""

echo "Paste in the URLs, use Ctrl+D when finished"
echo ""

while read URL; do
   if [[ -z "$URLS" ]]; then
      URLS=$URL
   else
      URLS="$URL $URLS"
   fi
done

echo ""
echo "Uploading the urls, a local copy is stored in \`~/tmp\`..."

echo $URLS | tee $HOME/tmp/$(date +%s).wall | ssh wallpapers "sed \"s/ /\n/g\" >> drop/$HOSTNAME-$(date +%s)"
