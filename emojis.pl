use strict;
use vars qw($VERSION %IRSSI);
use List::Util qw(max);
use Text::CharWidth qw(mbswidth);

use Irssi;

$VERSION = '1.21';

%IRSSI = (
    authors     => 'Alexandre Gauthier',
    contact     => 'alex@underwares.org',
    name        => 'Knifa-mode for irssi',
    description => 'This script pretty much allows you spam ' .
                   'horrible japanese smileys. Use at your own ' .
                   'risk.',
    license     => 'Public Domain',
    url         => 'https://github.com/mrdaemon/irssi-emojis',
);

# Default values
my $default_emojis_file = Irssi::get_irssi_dir() . "/emojis-db.dat";

# internal structures and variables
my %EMOJIS = ();
my $locked = 0;

# void load_emojis()
# Load the emojis from the file specified in the 'knifamode_dbfile'
# setting in the irssi configuration. Format is trigger on a line, emoji
# on the following one, repeat until end of file.
sub load_emojis {
    my $dbfile = Irssi::settings_get_str('knifamode_dbfile');

    if ( -e $dbfile && -r $dbfile) {
        open my $fh, '<utf8', $dbfile or die "Unable to read $dbfile: $!";
        
        while(<$fh>) {
            chomp;
            my $line = $_;
            my $nextline;

            # Horrible sanity check, ensure line starts with
            # a colon. Once validated, assume the next line is the emoji text.
            if ($line =~ m/^:/) {
                $nextline = <$fh>;
                chomp($nextline);
                $EMOJIS{$line} = $nextline; # Add key/value to hash
            } else {
                Irssi::print("Malformed line in emoji db: $line. Skipping.");
            }

        }
    } else {
        Irssi::print("emojis.pl: No such file, or acces denied: $dbfile");
    }
}

# void reload_emojis()
# Reloads the emojis database from file
sub reload_emojis {
    %EMOJIS = ();
    load_emojis();

    Irssi::print("Reloading emojis database from file...");

    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'loadbanner', 
        Irssi::settings_get_str('knifamode_dbfile')); 
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'statusbanner', 
        scalar(keys %EMOJIS));
}

# void knifaize($data, $server, $witem)
# Parses input line in $data, replaces emojis and emits
# the signal back where it came from.
sub knifaize {
    my ($data, $server, $witem) = @_;

    my $enabled = Irssi::settings_get_bool('knifamode_enable');
    my $signal = Irssi::signal_get_emitted();

    return unless ($enabled && !$locked);

    # Do not filter commands
    if ($data =~ /^\//) { return };

    while ( my($trigger, $emoji) = each(%EMOJIS) ) {
        $data =~ s/$trigger/$emoji/g;
    }

    # event with shit mutex, lawl
    $locked = 1;
    Irssi::signal_emit("$signal", $data, $server, $witem);
    Irssi::signal_stop();
    $locked = 0;
}

sub emojitable {
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'tblh', "List of emojis");
    while ( my($trigger, $emoji) = each(%EMOJIS) ) {
        Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'tbl', $trigger);
        Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'tbl', "   $emoji");
    }
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'tblf', "End emojis");
}

sub ensureLength {
    my $length = @_[0];
    my $filler = @_[1];
    my $str = @_[2];
    my $result = $str;
    while(mbswidth($result) < $length) {
	$result .= $filler;
    }
    return $result;
}

sub emojifill {
    my $leftmargin = 16;  # TODO should depend on timestamp format etc
    my $width = Irssi::active_win()->{'width'} - $leftmargin;
    my $spacing = 4;
    my $spacingString = "    ";
    my @emojis = ();
    my @triggers = ();

    #  Insert tuples into rows with greedy algo: fill longest lines first
    while ( my($trigger, $emoji) = each(%EMOJIS) ) {
	my $tupleLength =
	    max(mbswidth($trigger), mbswidth($emoji)) + $spacing;
	my $adjustedTrigger = ensureLength($tupleLength, " ", $trigger);
	my $adjustedEmoji = ensureLength($tupleLength, " ", $emoji);

	if ($#emojis == -1) {
	    #  First tuple, add to new line
	    push(@emojis, $adjustedEmoji);
	    push(@triggers, $adjustedTrigger);
	} else {
	    my $didPut = 0;
	    #  Add tuple to longest possible line
	    for (my $i=0; $i < $#emojis; $i++) {
		if (mbswidth(@emojis[$i]) + mbswidth($adjustedEmoji)
		  <= $width) {
		    @emojis[$i] = @emojis[$i] .= $adjustedEmoji;
		    @triggers[$i] = @triggers[$i] .= $adjustedTrigger;
		    $didPut = 1;
		    last;
		}
	    }
	    if ($didPut == 0) {
		#  If no line could fit tuple, put in new line
		push(@emojis, $adjustedEmoji);
		push(@triggers, $adjustedTrigger);
	    }

	    #  Sort lines with longest first
	    @emojis = sort {mbswidth $b <=> mbswidth $a} @emojis;
	    @triggers = sort {mbswidth $b <=> mbswidth $a} @triggers;
	}
    }
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'tblh', "List of emojis");
    for (my $i=0; $i < $#emojis; $i++) {
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'tbl', @triggers[$i]);
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'tbl', @emojis[$i]);
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'tbl', "");
    }
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'tblf', "End emojis");
}

# Settings
Irssi::settings_add_bool('lookandfeel', 'knifamode_enable', 1);
Irssi::settings_add_str('lookandfeel', 'knifamode_dbfile',
                            $default_emojis_file);

# hooks
Irssi::signal_add_first('send command', 'knifaize');

# commands
Irssi::command_bind emojis => \&emojitable;
Irssi::command_bind emoji => \&emojifill;
Irssi::command_bind reloademojis => \&reload_emojis;

# Register formats for table-like display.
# This was mostly shamelessly lifted from scriptassist.pl
Irssi::theme_register(
    [
        'tblh', '%R,--[%n$*%R]%n',
        'tbl', '%R|%n $*',
        'tblf', '%R`--[%n$*%R]%n',
        'banner', '%R>>%n %_Knifamode:%_ $0 initialized, version $1',
        'statusbanner', '%R>>%n %_Knifamode:%_ Loaded $0 knifaisms.',
        'loadbanner', '%R>>%n %_Knifamode:%_ Loading emojis from $0 ...',
        'statusmsg', '%R>>%n %_Knifamode:%_ - $0 -'
    ]
);

# main():

Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'loadbanner', 
    Irssi::settings_get_str('knifamode_dbfile')); 

load_emojis();

Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'banner', $IRSSI{name}, $VERSION);
Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'statusbanner', scalar(keys %EMOJIS));
Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'statusmsg',
    "Use /emoji or /emojis to list available triggers.");

###
