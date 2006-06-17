package OptionMenu;
use strict;
use POSIX;
use Gtk;

sub new {
    my $class = shift;
    my $callback = shift;

    my $o = {
	menuitem => [],
	menu => 0,
	label => {},
	callback => $callback
	};

    $o->{menu} = new Gtk::Menu;

    bless $o;
    return $o;
}

sub add {
    my $o = shift;
    my $string = shift;

    my $item = Gtk::MenuItem->new_with_label($string);
    $item->signal_connect('activate', $o->{callback}, $string);

    $o->{menu}->append($item);

    $o->{label}->{$string} = scalar(@{$o->{menuitem}});

    $item->show();

    push(@{$o->{menuitem}}, $item);
}

sub clear {
    my $o = shift;

    $o->{menu}->destroy();
    undef $o->{menu};
    undef $o->{label};

    foreach my $i (@{$o->{menuitem}}) {
	$i->destroy();
	undef $i;
    }
}

1;

    
    
	
