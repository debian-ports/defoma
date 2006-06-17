BEGIN {
    use lib "/usr/share/perl5/Debian/DefomaWizard";
    use DefomaWizard;
    use Gtk;
    Gtk->init();
}

sub dialog1 {
    my $r = &defomawizard::main(@_, title => $DIALOGTITLE);

    $result = &defomawizard::get_status();
    
    if ($result == 255) {
	exitfunc(255, 'Window got closed.');
    }

    return $r;
}

sub dialog2 {
    my @r = &defomawizard::main(@_, title => $DIALOGTITLE);

    $result = &defomawizard::get_status();
    
    if ($result == 255) {
	exitfunc(255, 'Window got closed.');
    }

    return @r;
}

sub msgbox {
    my $text = shift;
    $text =~ s/\\n/\n/gm;
    
    dialog1(type => 'note', text => $text);

    return 0;
}

sub infobox {
    msgbox(@_);
}

sub yesnobox {
    my $text = shift;
    $text =~ s/\\n/\n/gm;

    my $ret = dialog1(type => 'yesno', text => $text);

    return 1 if ($result != 0);

    return 0 if ($ret eq 'yes');
    return 1;
}

sub inputbox {
    my $text = shift;
    my $default = shift;
    my $pattern = shift;
    my $allowempty = shift;
    my @args;
    my $ret;
    $text =~ s/\\n/\n/gm;

    while(1) {
	$ret = dialog1(type => 'entry', text => $text, pretext => $default);

	return '' if ($result != 0);
	return '' if ($ret eq '' && $allowempty != 0);
	return $ret if ($ret =~ /^$pattern+$/);

	if ($ret eq '') {
	    $text = "Empty is not allowed.";
	} else {
	    $default = $ret;
	    $ret =~ s/$pattern//g;
	    $default =~ s/[^$ret]/_/g;
	    $text = "Illegal characters: \"$ret\".";
	    if ($ret =~ / /) {
		$text .= "\n you can use underscore in place of space.";
	    }
	}
    }
}

sub menu_single(@) {
    my $text = shift;
    my $menu_height = shift;
    my $defaultitem = shift;
    $text =~ s/\\n/\n/gm;

    my @items = @_;
    my %add;

    if ($defaultitem) {
	for (my $i = 0; $i < @items; $i++) {
	    if ($items[$i] eq $defaultitem) {
		$add{preselect} = $i;
	    }
	}
    }

    my $r = dialog1(type => 'singlelist', text => $text,
		    items => \@items, %add);

    return '' if ($result != 0);

    return $items[$r];
}

sub checklist_single_onargs {
    my $text = shift;
    my $menu_height = shift;
    my $onargs = shift;
    $text =~ s/\\n/\n/gm;

    my @items = @_;
    my @onoff = ();
    my @ons = split(' ', $onargs);

    for ($i = 0; $i < @items; $i++) {
	push(@onoff, (grep($_ eq $items[$i], @ons)) ? 1: 0);
    }

    my @ret = dialog2(type => 'multilist', text => $text,
		      items => \@items, onoff => \@onoff);

    my @retstr = ();
    for (my $i = 0; $i < @ret; $i++) {
	push(@retstr, $items[$i]) if ($ret[$i]);
    }

    return join("\n", @retstr);
}

sub input_menu {
    my $input_text = shift;
    my $default = shift;
    my $input_pattern = shift;
    my $input_allowempty = shift;
    my $input_menu_item = '';
    my $menu_text = '';
    my @menu_list = ();
    if (@_ >= 3) {
	$input_menu_item = shift;
	$menu_text = shift;
	@menu_list = @_;
    }

    while (1) {
	if (@menu_list > 0) {
	    chomp($menu_text);

	    my $ret;

	    $ret = menu_single($menu_text, $items, $default,
				   @menu_list);
	    
	    return '' if ($result != 0);
	    return $ret if ($ret ne $input_menu_item);
	}
	
	chomp($input_text);

	$ret = inputbox($input_text, $default, $input_pattern,
			$input_allowempty);
	return $ret if ($result == 0 || $menu_text eq '');
    }
}

sub input_menu2 {
    my $input_text = shift;
    my $default = shift;
    my $input_pattern = shift;
    my $input_allowempty = shift;
    if (@_ >= 3) {
	$input_menu_item = shift;
	$menu_text = shift;
    }

    my @new_list = ();

    while (@_ > 0) {
	my $a = shift;
	my $b = shift;
	push(@new_list, $a);
    }

    input_menu($input_text, $default, $input_pattern, $input_allowempty,
	       $input_menu_item, $menu_text, @new_list);
}

sub input_checklist {
    my $input_text = shift;
    my $default = shift;
    my $input_pattern = shift;
    my $input_allowempty = shift;
    my $clist_text = '';
    my @clist_list = ();
    if (@_ > 0) {
	$clist_text = shift;
	@clist_list = @_;
    }

    while (1) {
	chomp($clist_text);
	
	my $ret;
	
	$ret = checklist_single_onargs($clist_text, $items, $default,
				       @clist_list);
	return '' if ($result != 0);
	chomp($ret);
	$ret =~ s/\n/ /g;
    	
	$ret = inputbox($input_text, $ret, $input_pattern, $input_allowempty);
	return $ret if ($result == 0);
    }
}

1;
