use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'File::chmod::Recursive',
    license             => 'perl',
    dist_author         => 'Mithun Ayachit <mithun@cpan.org>',
    dist_version_from   => 'lib/File/chmod/Recursive.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'File-chmod-Recursive-*' ],
);

$builder->create_build_script();
