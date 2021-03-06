#!/bin/bash

INSTALLDIR=$HOME/irssi-emojis
IRSSIDIR=$HOME/.irssi

echo -e "✨ Installing emojis for irssi! ✨ "
echo -e ""

if [[ $EUID == 0 ]]; then
   echo "Don't install this as root!" 
   exit 1
fi

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

if [ ! -d $IRSSIDIR/scripts/autorun ]; then
  read -p "Would you like to autorun this script when irssi is started? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo -e "📂Creating autorun directory"
    mkdir $IRSSIDIR/scripts/autorun
  fi
fi

if [ -d $IRSSIDIR/scripts/autorun ]; then
  echo -e "➕Enabling autorun of the script."
  ln -sf $INSTALLDIR/emojis.pl $IRSSIDIR/scripts/autorun/emojis.pl
fi
echo -e ""
echo -e "ℹ️Load load script in irssi using '/script load emojis'"
echo -e ""
echo -e "Thanks for installing emojis! 👍"
echo -e ""
