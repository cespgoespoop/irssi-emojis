#!/bin/bash

INSTALLDIR=$HOME/irssi-emojis
IRSSIDIR=$HOME/.irssi

if [ ! -d $INSTALLDIR ]; then
  git clone https://github.com/cespgoespoop/irssi-emojis.git
fi


echo -e "✨ Installing emojis for irssi! ✨ "
echo -e ""
ln -sf $INSTALLDIR/emojis-db.dat $IRSSIDIR/emojis-db.dat
ln -sf $INSTALLDIR/emojis.pl $IRSSIDIR/scripts/emojis.pl

if [ -d $IRSSIDIR/scripts/autorun ]; then
  echo -e "➕Enabling autorun of the script."
  ln -sf $INSTALLDIR/emojis.pl $IRSSIDIR/scripts/autorun/emojis.pl
fi
echo -e ""
echo -e "ℹ️Load load script in irssi using '/script load emojis'"
echo -e ""
echo -e "Thanks! 👍"
