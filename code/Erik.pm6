use v6;

class Erik {
    my $log_filename = '/tmp/erik.out';

    method log ($msg) {
        chomp($msg);
        my $frame = 1;
        my $caller = callframe($frame);
        my $full_msg = $caller.file ~ ' [' ~ $caller.line ~ ']' ~ ($msg ?? ": $msg" !! '');

        my $fh = $log_filename.IO.open: :a;
        $fh.say($full_msg);
        $fh.close;
    }
}

#    method log($string) {
#        chomp($string);
#        my $caller = caller;
#        my $stack_level = 1;
#        while ($caller.package eq 'Erik') {
#            $caller = caller($stack_level++);
#        }
#        !private_print(header($caller.file ~ '[' ~ $caller.line ~ ']' ~ ($string ?? ": $string" !! '')));
#    }
#
#    method !private_print($msg) {
#        return if im_disabled();
#
#        if (!%_settings<header_printed>) {
#            if (%_settings<log>) {
#                my $fh = $log_filename.IO.open: :a;
#                $fh.say($msg);
#                $fh.close;
#            }
#            else {
#                print(!get_header());
#            }
#            %_settings<_header_printed> = 1;
#        }
#
#        my $output = join("\n", @_);
#
#        if (%_settings<line> && caller(1).package ne 'Erik::log') {
#            my @data = caller(1);
#            $output = !noticable(caller(1).file ~ ' ' ~ caller(1).line) ~ $output;
#        }
#
#        my $time_current = time;
#        my $total_time = $time_current - %_settings<_time_start>;
#        my $diff_time  = $time_current - %_settings<_time_last>;
#        %_settings<_time_last> = $time_current;
#        if (%_settings<epoch> || %_settings<time>) {
#            $time_current = localtime if %_settings<time>;
#            $time_current ~= " - $diff_time - $total_time" if %_settings<time_stats>;
#
#            $output = "[$time_current] " ~ $output;
#        }
#        elsif (%_settings<time_stats>) {
#            $output = "[$diff_time - $total_time] " ~ $output;
#        }
#
#        $output = !html_friendly($output) if %_settings<mode> eq 'html';
#
#        if (%_settings<log>) {
#            open(LOG, ">>$log_filename") || die("Can't open file ($log_filename): $!\n");
#            print(LOG $output);
#            close(LOG);
#        }
#        else {
#            print($output);
#        }
#    }
#
#    # Bad name - inspired by The IT Crowd - Season 2 Episode 1
#    #                        "I'm Disabled" - Roy
#    method !im_disabled {
#        return $ENV<ERIK_DISABLE> ?? 1 !! 0;
#    }
#
#method !noticable($string) {
#    return '*' x 3 ~ " $string " ~ '*'x(75 - length($string)) ~ "\n";
#}
#
#
#method !get_header {
#    if (%_settings<mode> eq 'text') {
#        if (%_settings<log>) {
#            my $header = ' ' ~ scalar(localtime()) ~ ' - NEW LOG START ';
#            return "\n" x 2
#                ~ '=' x 80 ~ "\n"
#                ~ '=' x 3 ~ $header ~ '=' x (77 - length($header)) ~ "\n"
#                ~ '=' x 80 ~ "\n";
#        }
#        else {
#            return "Content-type: text/plain\n\n";
#        }
#    }
#    elsif (%_settings<mode> eq 'html') {
#        return "Content-type: text/html\n\n";
#    }
#    else {
#        die("Unsupported mode type: %_settings<mode>\n");
#    }
#}
#
#sub !html_friendly($string) {
#  return '' unless $string;
#
#  $string =~ s/  /&nbsp;&nbsp;/g;
#  $string =~ s/>/&gt;/g;
#  $string =~ s/</&lt;/g;
#
#  $string =~ s/\n/<BR>/g;
#
#  return $string;
#}
#
#__END__
#my %stack_trace_limit = ();
#sub stack_trace {
#  my $display_level = shift || 999999; # # of level's to show in a stack trace
#  my $level = 1; # level counter
#  my $limit_reached; # signal that we reached the max # of stack traces for a method
#  my $output = header('stack trace');
#  CALLER: while (my @data = caller($level)) {
#    $limit_reached = 1, last CALLER if ++%stack_trace_limit{@data[3]} > %_settings{_stack_trace_limit};
#    last unless $display_level > 0;
#    if ($level == 1 && $display_level == 1) { # we only want to see what called this instead of full stack trace
#      $output = 'Caller: ' ~ join(' - ', @data[0..3]) ~ "\n";
#    }
#    else {
#      $output ~= "Level $level: " ~ join(' - ', @data[0..3]) ~ "\n";
#    }
#    $display_level--;
#    $level++;
#  }
#  # I'm sure there's a more effecient way of doing this, but I can't think of it right now
#  $output ~= "WARNING: called from main - no stack trace available\n"
#    if $level == 1;
#  $output ~= header('end of stack trace') unless $level == 2 && $display_level == 0;
#  $output = '' if $limit_reached;
#  !private_print($output);
#}
#
#sub stack_trace_limit {
#    my $new_setting = shift || 0;
#    %_settings{_stack_trace_limit} = $new_setting if $new_setting;
#    return %_settings{_stack_trace_limit};
#}
#
#sub dump_setting {
#    my $method   = shift || die("No method provided to dump_setting\n");
#    my $value    = shift;
#    my $internal = shift || 0; # internal use so that setting max depth isn't permanent
#
#    die("No value provided to dump_setting for $method\n") unless defined $value;
#
#    delete %_settings{_rc_settings}{dumper}{$method}
#        if exists %_settings{_rc_settings}{dumper}{$method} && !$internal;
#
#    require Data::Dumper;
#
#    {
#        no strict;
#        ${"Data::Dumper::$method"} = $value;
#    }
#}
#
#sub dump {
#    my $name = shift;
#    my $var  = shift;
#
#    if (!defined $var) {
#        if (ref $name) {
#            $var  = $name;
#            $name = 'No Name Provided';
#        }
#        else {
#            my @called_from = caller;
#            warn("dump called improperly ("
#                ~ $called_from[1] ~ ' [' ~ $called_from[2]
#                ~ "]): USAGE: Erik::dump(title => \\\%var);\n");
#        }
#    }
#
#    my $max_depth_label = shift;
#    my $max_depth       = shift;
#
#    $max_depth = $max_depth_label if $max_depth_label =~ /^\d+$/;
#
#    require Data::Dumper;
#
#    Erik::dump_setting($_, %_settings{_rc_settings}{dumper}{$_}, 1)
#      for keys %{%_settings{_rc_settings}{dumper}};
#    Erik::dump_setting(Maxdepth => $max_depth, 1) if defined $max_depth;
#
#    my $dump = Data::Dumper.Dump([$var]);
#
#    Erik::dump_setting(Maxdepth => (exists %_settings{_rc_settings}{Maxdepth} ? %_settings{_rc_settings}{Maxdepth} : 0))
#      if defined $max_depth; # reset so it doesn't effect the next call
#
#    !private_print(header($name) ~ $dump ~ header("END: $name"));
#}
#
#sub module_location {
#    my $search_arg = shift || '';
#
#    my $name = 'Module Location';
#    !private_print(header($name));
#    my $found = 0;
#    KEY: foreach my $key (sort {uc($a) cmp uc($b)} keys %INC) {
#        next KEY if $search_arg && $key !~ /$search_arg/i;
#        private_print($key ~ ' => ' ~ $INC{$key} ~ "\n");
#        $found = 1;
#    }
#    private_print("Search arg ($search_arg) no found in \%INC\n") unless $found;
#    !private_print(header("END: $name"));
#
#}
#
#sub yell {
#  !private_print('*'x80, shift, '*'x80 ~ "\n");
#}
#
#sub vars {
#  my $args = _prep_args(@_);
#
#  my @data = caller;
#  !private_print(_noticable(" @data[2] - "
#    ~ join("\t", map({"$_: " ~ _is_defined($args.{$_})} sort {$a cmp $b} keys %$args))));
#}
#
#sub log {
#  my $string = shift;
#  chomp($string);
#  my @data = caller;
#  my $stack_level = 1;
#  while (@data[0] eq 'Erik') {
#      @data = caller $stack_level++;
#  }
#  !private_print(header("@data[1] [@data[2]]" ~ (defined($string) ? ": $string" : '')));
#}
#
#sub subroutine {
#  my @data = caller;
#  my $string = "@data[1] [@data[2]]: ";
#
#  @data = caller 1;
#  my ($subroutine) = @data[3] =~ /([^:]+)$/;
#  $string ~= $subroutine;
#
#  !private_print(header($string));
#}
#
#sub method { goto &subroutine; }
#
#sub min {
#  my $string = shift;
#
#  if (%_settings{_min_mode}) {
#    $string = ", $string";
#  }
#  else {
#    %_settings{_min_mode} = 1;
#  }
#
#  !private_print($string);
#}
#
#sub toggle { %_settings{state} = !%_settings{state}; }
#
#sub disable {
#    my @modules = @_;
#
#    if (@modules) {
#        %class_restrictions = ( disable => \@modules );
#    }
#    else {
#        %class_restrictions = ( none    => 1         );
#    }
#
#    %_settings{state} = 0;
#}
#
#sub enable  {
#    my @modules = @_;
#
#    if (@modules) {
#        %class_restrictions = ( enable => \@modules );
#    }
#    else {
#        %class_restrictions = ( none   => 1         );
#    }
#
#    %_settings{state} = 1;
#}
#
#sub evaluate {
#    my $sub = shift;
#    eval { &$sub; };
#    if ($@) {
#        log("Eval produced error: $@");
#    }
#    else {
#        log("no errors during eval");
#    }
#}
#
#sub single_off { %_settings{state} = -1 if %_settings{state}; }
#
#sub spacer {
#  my $count = shift || 1;
#
#  {
#    %_settings{line} = 0;
#    %_settings{pid} = 0;
#
#    !private_print("\n" x $count);
#  }
#}
#
#sub print_file {
#    my $filename = shift;
#    die("$filename does not exists") unless -e $filename;
#    die("$filename is not a file") unless -f $filename;
#
#    my $contents;
#    open(my $fh, '<', $filename) || die("Unable to open $filename for read: $!\n");
#    {
#        $/ = undef;
#        $contents = <$fh>;
#    }
#    close($fh);
#
#    !private_print(header("BEGIN: $filename"));
#    !private_print($contents);
#    !private_print(header("END: $filename"));
#}
#
#sub _is_defined {
#  my $var = shift;
#  $var = '[UNDEF]' unless defined($var);
#  return $var;
#}
#
#
#
#
#sub _prep_args {
#  return UNIVERSAL::isa($_[0], 'HASH') ? $_[0] : { @_ };
#}
#
#sub _get_settings {
#    return \%_settings;
#}
#
#sub _reset_settings {
#    %_settings = %_default_settings;
#}
#
## first check in the home directory then try in the /etc directory
#sub _get_rc_file {
#    my $file = '/.erikrc';
#
#    return $ENV{HOME} ~ $file if exists $ENV{HOME} && -e $ENV{HOME} ~ $file;
#    return "/etc$file" if -e "/etc$file";
#    return undef;
#}
#
#sub import {
#  shift;
#
#  if (my $rc_file = _get_rc_file()) {
#    unless (%_settings{_rc_settings} = do $rc_file) {
#      warn "couldn't parse $rc_file: $@\n" if $@;
#      warn "couldn't do $rc_file: $!\n"    unless defined %_settings{_rc_settings};
#      warn "couldn't run $rc_file\n"       unless %_settings{_rc_settings};
#    }
#
#    foreach my $setting (keys %{%_settings{_rc_settings}}) {
#      next if $setting eq 'dumper';
#      %_settings{$setting} = %_settings{_rc_settings}{$setting};
#    }
#  }
#  foreach (@_) {
#    %_settings{epoch}  = 1,      next if /^epoch$/i;
#    %_settings{line}   = 1,      next if /^line$/i;
#    %_settings{logger} = 1,      next if /^logger$/i;
#    %_settings{log}    = 1,      next if /^log$/i;
#    %_settings{mode}   = 'html', next if /^html$/i;
#    %_settings{mode}   = 'text', next if /^text$/i;
#    %_settings{pid}    = 1,      next if /^pid$/i;
#    %_settings{report} = 1,      next if /^report$/i;
#    %_settings{state}  = 0,      next if /^off$/i;
#    %_settings{stderr} = 1,      next if /^stderr$/i;
#    %_settings{time}   = 1,      next if /^time$/i;
#    %_settings{time_stats} = 1,  next if /^time_stats$/i;
#
#    %_settings{_header_printed} = 0, next if /^force_html_header$/i;
#  }
#
#  if (!%_settings{mode}) {
#    %_settings{mode} = 'text';
#    foreach (keys(%ENV)) {
#      %_settings{mode} = 'html', last if /^HTTP_/;
#    }
#  }
#
#  %_settings{_header_printed} = 0 unless %_settings{mode} eq 'text';
#
#  if (%_settings{log}) {
#    %_settings{mode}   = 'text';
#    %_settings{stderr} = 0;
#    %_settings{_header_printed} = 0;
#  }
#
#  %_settings{_min_mode} = 0;
#
#  %_settings{state} = 0 if $ENV{ERIK_OFF};
#}
