use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name        => 'File::chmod::Recursive',
    license            => 'perl',
    dist_author        => 'Mithun Ayachit <mithun@cpan.org>',
    dist_version_from  => 'lib/File/chmod/Recursive.pm',
    dist_abstract      => 'Run chmod recursively against directories',
    configure_requires => { 'Module::Build' => 0, },
    build_requires     => { 'Test::More' => 0, },
    requires           => { 'File::chmod' => '0.32', },
    add_to_cleanup     => ['File-chmod-Recursive-*'],
    create_readme      => 1,
    meta_add           => {
        repository => {
            url  => 'git://github.com/mithun/perl-file-chmod-recursive.git',
            web  => 'https://github.com/mithun/perl-file-chmod-recursive',
            type => 'git',
        },
    },

);

$builder->create_build_script();
