package PerlIO::via::Pod;

# Set the version info
# Make sure we do things by the book from now on

$VERSION = '0.01';
use strict;

# Satisfy -require-

1;

#-----------------------------------------------------------------------

# Subroutines for standard Perl features

#-----------------------------------------------------------------------
#  IN: 1 class to bless with
#      2 mode string (ignored)
#      3 file handle of PerlIO layer below (ignored)
# OUT: 1 blessed object

sub PUSHED { 

# Die now if strange mode
# Create the object with the right fields

#    die "Can only read or write with line numbers" unless $_[1] =~ m#^[rw]$#;
    bless {inpod => 0},$_[0];
} #PUSHED

#-----------------------------------------------------------------------
#  IN: 1 instantiated object
#      2 handle to read from
# OUT: 1 processed string (if any)

sub FILL {

# Create local copy of $_
# While there are lines to be read from the handle
#  If we're in what looks like a pod line
#   Return now if it is not an end-pod line, setting flag on the fly
#  Elseif we're now in pod
#   Return the line
# Return indicating end reached

    local( $_ );
    while (defined( $_ = readline( $_[1] ) )) {
	if (m#^=\w#) {
            return $_ if $_[0]->{'inpod'} = !m#^=cut#;
        } elsif ($_[0]->{'inpod'}) {
            return $_;
        }
    }
    undef;
} #FILL

#-----------------------------------------------------------------------
#  IN: 1 instantiated object
#      2 buffer to be written
#      3 handle to write to
# OUT: 1 number of bytes written

sub WRITE {

# For all of the lines in this bunch (includes delimiter at end)
#  If it looks like a pod line
#   If it is not an end pod, setting flag on the fly
#    Print the line, return now if failed
#  Elseif we're in pod now
#   Print the line, return now if failed
# Return total number of octets handled

    foreach (split( m#(?<=$/)#,$_[1] )) {
	if (m#^=\w#) {
            if ($_[0]->{'inpod'} = !m#^=cut#) {
                return -1 unless print {$_[2]} $_;
            }
        } elsif ($_[0]->{'inpod'}) {
            return -1 unless print {$_[2]} $_;
        }
    }
    length( $_[1] );
} #WRITE

#-----------------------------------------------------------------------

__END__

=head1 NAME

PerlIO::via::Pod - PerlIO layer for extracting plain old documentation

=head1 SYNOPSIS

 use PerlIO::via::Pod;

 open( my $in,'<:via(Pod)','file.pm' )
  or die "Can't open file.pm for reading: $!\n";
 
 open( my $out,'>:via(Pod)','file.pm' )
  or die "Can't open file.pm for writing: $!\n";

=head1 DESCRIPTION

This module implements a PerlIO layer that extracts plain old documentation
(pod) on input B<and> on output.  It is intended as a development tool only,
but may have uses outside of development.

=head1 EXAMPLES

Here are some examples, some may even be useful.

=head2 Pod only filter

A script that only lets plain old documentation pass.

 #!/usr/bin/perl
 use PerlIO::via::Pod;
 binmode( STDIN,':via(Pod)' ); # could also be STDOUT
 print while <STDIN>;

=head1 SEE ALSO

L<PerlIO::via>, L<PerlIO::via::UnPod> and any other PerlIO::via modules on CPAN.

=head1 COPYRIGHT

Copyright (c) 2002 Elizabeth Mattijsen.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
