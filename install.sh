#!/bin/bash

INSTALLDIR=$HOME/irssi-emojis
IRSSIDIR=$HOME/.irssi

echo -e "✨ Installing emojis for irssi! ✨ "
echo -e ""

if [ ! -d $INSTALLDIR ]; then
  git clone https://github.com/cespgoespoop/irssi-emojis.git
fi

if [ ! -d $IRSSIDIR ]; then
  echo -e "📂Creating irssi configuration directory"
  mkdir $IRSSIDIR
fi

if [ ! -d $IRSSIDIR/scripts ]; then
  echo -e "📂Creating scripts directory"
  mkdir $IRSSIDIR/scripts
fi

ln -sf $INSTALLDIR/emojis-db.dat $IRSSIDIR/emojis-db.dat
ln -sf $INSTALLDIR/emojis.pl $IRSSIDIR/scripts/emojis.pl

read -p "Would you like to enable autorun? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  mkdir $IRSSIDIR/scripts/autorun
fi

if [ -d $IRSSIDIR/scripts/autorun ]; then
  echo -e "➕Enabling autorun of the script."
  ln -sf $INSTALLDIR/emojis.pl $IRSSIDIR/scripts/autorun/emojis.pl
fi
echo -e ""
echo -e "ℹ️Load load script in irssi using '/script load emojis'"
echo -e ""
echo -e "Thanks! 👍"
