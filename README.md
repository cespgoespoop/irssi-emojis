Automagical emoji tags using Github/Campfire's code names


EZ MODE!
------------

    /bin/bash -c "wget -q https://raw.githubusercontent.com/cespgoespoop/irssi-emojis/master/install.sh && /bin/bash install.sh"

[![asciicast](https://asciinema.org/a/p9oy0WjeImAHaIvy9tNnamuB2.svg)](https://asciinema.org/a/p9oy0WjeImAHaIvy9tNnamuB2)


Manual Instructions
------------

 1. Copy emojis.pl to ~/.irssi/scripts
 2. Copy  emojis-db.dat to ~/.irssi/
 3. Run '/script load emojis' in irssi
 4. Use /emojis to display the list available emojis
 5. Marvel at your ability to use things like `:poop:` :poop:

You may add your own to the database, format is:

    :trigger:
    smiley

Your trigger *MUST* begin with ':'.

Note
----

This is merely [mrdaemon][code]'s original script with a modified `dat`
file to display customized Unicode smileys & co.


[code]: https://github.com/mrdaemon/irssi-emojis
