package File::chmod::Recursive;

#######################
# VERSION
#######################
our $VERSION = '0.01';

#######################
# LOAD MODULES
#######################
use strict;
use warnings FATAL => 'all';
use Carp qw(croak carp);
use Cwd qw(abs_path);
use File::Find qw(finddepth);
use File::chmod qw(chmod);

#######################
# EXPORT
#######################
use base qw(Exporter);
our (@EXPORT);

@EXPORT = qw(chmod_recursive);

#######################
# CHMOD RECURSIVE
#######################
sub chmod_recursive {

    # Read Input
    my @in = @_;

    # Check Input
    my $mode = {
        files => q(),
        dirs  => q(),
        match => {},
    };
    my $dir;
    if ( ref $in[0] eq 'HASH' ) {
## Usage chmod_recursive({}, $dir);

        # Both files and Directories are required
        $mode->{files} = $in[0]->{files} || croak "File mode is not provided";
        $mode->{dirs} = $in[0]->{dirs}
            || croak "Directory mode is not provided";

        # Check for match
        if ( $in[0]->{match} ) {
            croak "Hash ref expected for _match_"
                unless ( ref $in[0]->{match} eq 'HASH' );
            foreach ( keys %{ $in[0]->{match} } ) {
                croak "$_ is not a compiled regex"
                    unless ( ref $_ eq 'Regexp' );
            }
            $mode->{match} = $in[0]->{match};
        } ## end if ( $in[0]->{match} )
    } ## end if ( ref $in[0] eq 'HASH')
    else {
## Usage chmod_recursive($mode, $dir);

        # Set modes
        $mode->{files} = $in[0];
        $mode->{dirs}  = $in[0];
    } ## end else [ if ( ref $in[0] eq 'HASH')]

    # Get directory
    $dir = $in[1] || croak "Directory not provided";
    $dir = abs_path($dir);
    if ( -l $dir ) {
        $dir = readlink($dir) || croak "Failed to resolve symlink $dir";
    }
    croak "$dir is not a directory" unless -d $dir;

    # Run chmod
    #   This uses _finddepth_
    #   which works from the bottom of the directory tree up
    my @updated;
    {

        # Turn off warnings for file find
        no warnings 'File::Find';
        finddepth(
            {
                follow => 1,  # Follow symlinks
                follow_skip =>
                    2,        # But ignore duplicates and continue processing
                no_chdir => 1,    # Do not chdir
                wanted   => sub {

                    # The main stuff

                    # Get full path
                    my $path = $File::Find::name;

                    # Check for symlinks
                    if ( -l $path ) {
                        $path = $File::Find::fullname;
                    }

                    if ( -e $path ) {  # Skip dangling symlinks

                        # Process match
                        my $isa_match = 0;
                        foreach my $match_re ( keys %{ $mode->{match} } ) {
                            next unless ( $path =~ m{$match_re} );
                            $isa_match = 1;
                            if ( chmod( $mode->{match}->{$match_re}, $path ) )
                            {
                                push @updated, $path;
                            }
                        } ## end foreach my $match_re ( keys...)

                        # Process files
                        if (
                            ( not $isa_match )  # Not a match
                            and ( -f $path )    # Is a file
                            and (
                                chmod( $mode->{files}, $path )
                            )                   # Successfuly changed mode
                            )
                        {
                            push @updated, $path;
                        } ## end if ( ( not $isa_match ...))

                        # Process dirs
                        if (
                            ( not $isa_match )  # Not a match
                            and ( -d $path )    # Is a directory
                            and (
                                chmod( $mode->{dirs}, $path )
                            )                   # Successfuly changed mode
                            )
                        {
                            push @updated, $path;
                        } ## end if ( ( not $isa_match ...))

                    } ## end if ( -e $path )

                },
            },
            $dir
        );
    }

    # Done
    return @updated;
} ## end sub chmod_recursive

#######################
1;

__END__

#######################
# POD SECTION
#######################
=pod

=head1 NAME

File::chmod::Recursive

=head1 DESCRIPTION

Run chmod recursively against directories

=head1 SYNOPSIS

    use File::chmod::Recursive;  # Exports 'chmod_recursive' by default

    # Apply identical permissions to everything
    #   Similar to chmod -R
    chmod_recursive( 0755, '/path/to/directory' );

    # Apply permissions selectively
    chmod_recursive(
        {
            dirs  => 0755,       # Mode for directories
            files => 0644,       # Mode for files
            match => {
                qr/\.sh|\.pl/ => 0755,  # Mode for executables
                qr/\.key/     => 0600,  # Secure files

                # Note: Matching applies to both directories and files
            },
        },
        '/path/to/directory'
    );

=head1 FUNCTIONS

=over

=item chmod_recursive(MODE, $path)

=item chmod_recursive(\%options, $path)

This function accepts two parameters. The first is either a I<MODE> or an
I<options hashref>. The second is the directory to work on. It returns the
number of files successfully changes, similar to L<chmod>.

When using a I<hashref> for selective permissions, the following options are
valid -

    {
        dirs  => MODE,       # Required. Mode for directories
        files => MODE,       # Required. Mode for files
        match => {           # Optional.
            qr/<some condition>/ => MODE,
        # Note: Matching applies to both directories and files
        },
    }
    
In all cases the I<MODE> is whatever L<File::chmod> accepts.

=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-file-chmod-recursive@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 SEE ALSO

-   L<File::chmod>

-   L<chmod>

-   L<Perl Monks thread on recursive perl
chmod|http://www.perlmonks.org/?node_id=61745>

=head1 AUTHOR

Mithun Ayachit  C<< <mithun@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011, Mithun Ayachit C<< <mithun@cpan.org> >>. All rights
reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE
SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE
STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE
SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND
PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE,
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY
COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE
SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO
LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR
THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut
