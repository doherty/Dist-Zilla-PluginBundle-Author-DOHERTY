package Dist::Zilla::PluginBundle::Author::DOHERTY;
# ABSTRACT: configure Dist::Zilla like DOHERTY
use strict;
use warnings;
# VERSION

=head1 SYNOPSIS

    # in dist.ini
    [@Author::DOHERTY]

=head1 DESCRIPTION

C<Dist::Zilla::PluginBundle::Author::DOHERTY> provides shorthand for
a L<Dist::Zilla> configuration approximate like:

    [Git::Check]
    [@Filter]
    -bundle = @Basic    ; Equivalent to using [@Basic]
    -remove = Readme    ; For use with [CopyReadmeFromBuild]
    -remove = ExtraTests

    [AutoPrereqs]
    [MinimumPerl]
    [Repository]
    [Bugtracker]
    :version = 1.102670 ; To set bugtracker
    web = http://github.com/doherty/%s/issues
    [PodWeaver]
    config_plugin = @DOHERTY
    [InstallGuide]
    [ReadmeFromPod]
    [CopyReadmeFromBuild]
    [CopyMakefilePLFromBuild]

    [Git::NextVersion]
    [PkgVersion]
    [NextRelease]
    filename = CHANGES
    format   = %-9v %{yyyy-MM-dd}d
    [CheckChangesHasContent]
    changelog = CHANGES

    [Twitter]       ; config in ~/.netrc
    [GithubUpdate]  ; config in ~/.gitconfig
    [Git::Commit]
    [Git::Tag]

    [@TestingMania]
    [LocalInstall]

=cut

# Dependencies
use autodie 2.00;
use Moose 0.99;
use Moose::Autobox;
use namespace::autoclean 0.09;

use Dist::Zilla 4.102341; # dzil authordeps
use Dist::Zilla::Plugin::Git::Check                     qw();
use Dist::Zilla::Plugin::AutoPrereqs                    qw();
use Dist::Zilla::Plugin::MinimumPerl                    qw();
use Dist::Zilla::Plugin::Repository                0.13 qw(); # v2 Meta spec
use Dist::Zilla::Plugin::Bugtracker            1.102670 qw(); # to set bugtracker in dist.ini
use Dist::Zilla::Plugin::PodWeaver                      qw();
use Dist::Zilla::Plugin::SurgicalPodWeaver       0.0015 qw(); # to avoid circular dependencies
use Dist::Zilla::Plugin::InstallGuide                   qw();
use Dist::Zilla::Plugin::ReadmeFromPod                  qw();
use Dist::Zilla::Plugin::CopyReadmeFromBuild     0.0015 qw(); # to avoid circular dependencies
use Dist::Zilla::Plugin::Git::NextVersion               qw();
use Dist::Zilla::Plugin::OurPkgVersion                  qw();
use Dist::Zilla::Plugin::NextRelease                    qw();
use Dist::Zilla::Plugin::CheckChangesHasContent         qw();
use Dist::Zilla::Plugin::Git::Commit                    qw();
use Dist::Zilla::Plugin::Git::Tag                       qw();
use Dist::Zilla::PluginBundle::TestingMania       0.003 qw(); # better deps tree & PodLinkTests
use Dist::Zilla::Plugin::InstallRelease           0.006 qw(); # to detect failed installs
use Dist::Zilla::Plugin::CheckExtraTests                qw();
use Dist::Zilla::Plugin::GithubUpdate              0.03 qw(); # Support for p3rl.org
use Dist::Zilla::Plugin::Twitter                  0.010 qw(); # Support for choosing WWW::Shorten::$site via WWW::Shorten::Simple
use WWW::Shorten::IsGd                                  qw(); # Shorten with WWW::Shorten::IsGd
use Dist::Zilla::Plugin::CopyMakefilePLFromBuild 0.0015 qw(); # to avoid circular dependencies

use Pod::Weaver::Section::BugsAndLimitations   1.102670 qw(); # to read from D::Z::P::Bugtracker
use Pod::Weaver::PluginBundle::Author::DOHERTY    0.004 qw(); # new name

with 'Dist::Zilla::Role::PluginBundle::Easy';

=head1 USAGE

Just put C<[@Author::DOHERTY]> in your F<dist.ini>. You can supply the following
options:

=over 4

=item *

C<fake_release> specifies whether to use C<L<FakeRelease|Dist::Zilla::Plugin::FakeRelease>>
instead of C<L<UploadToCPAN|Dist::Zilla::Plugin::UploadToCPAN>>. Defaults to 0.

=cut

has fake_release => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { $_[0]->payload->{fake_release} || 0 },
);

=item *

C<bugtracker> specifies a URL for your bug tracker. This is passed to C<L<Bugtracker|Dist::Zilla::Plugin::Bugtracker>>,
so the same interpolation rules apply. Defaults to C<http://github.com/doherty/%s/issues>.

=cut

has bugtracker => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { $_[0]->payload->{bugtracker} || 'http://github.com/doherty/%s/issues' },
);

=item *

C<add_tests> is a comma-separated list of testing plugins to add
to C<L<TestingMania|Dist::Zilla::PluginBundle::TestingMania>>.

=cut

has add_tests => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => '',
);

=item *

C<skip_tests> is a comma-separated list of testing plugins to skip in
C<L<TestingMania|Dist::Zilla::PluginBundle::TestingMania>>.

=cut

has skip_tests => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => '',
);

=item *

C<tag_format> specifies how a git release tag should be named. This is
passed to C<L<Git::Tag|Dist::Zilla::Plugin::Git::Tag>>.

=cut

has tag_format => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { $_[0]->payload->{tag_format} || 'release-%v' },
);

=item *

C<version_regex> specifies a regexp to find the version number part of
a git release tag. This is passed to C<L<Git::NextVersion|Dist::Zilla::Plugin::Git::NextVersion>>.

=cut

has version_regexp => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { $_[0]->payload->{version_regexp} || '^release-(.+)$' },
);

=item *

C<no_twitter> says that releases of this module shouldn't be tweeted.

=cut

has twitter => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        (defined $_[0]->payload->{no_twitter} and $_[0]->payload->{no_twitter} == 1) ? 0 : 1;
    },
);

=item *

C<surgical> says to use L<Dist::Zilla::Plugin::SurgicalPodWeaver>.

=cut

has surgical => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { $_[0]->payload->{surgical} || 0 },
);

=back

=cut

sub configure {
    my $self = shift;

    $self->add_plugins(
        # Version number
        [ 'Git::NextVersion' => { version_regexp => $self->version_regexp } ],
        'OurPkgVersion',

        # Gather & prune
        'GatherDir',
        'PruneCruft',
        'ManifestSkip',

        # Generate dist files & metadata
        'ReadmeFromPod',
        'License',
        'MinimumPerl',
        'AutoPrereqs',
        'MetaYAML',
        'Repository',
        [ 'Bugtracker' => { web => $self->bugtracker } ],

        # File munging
        ( $self->surgical
            ? [ 'SurgicalPodWeaver' => { config_plugin => '@Author::DOHERTY' } ]
            : [ 'PodWeaver'         => { config_plugin => '@Author::DOHERTY' } ]
        ),

        # Build system
        'ExecDir',
        'ShareDir',
        'MakeMaker',

        # Manifest stuff must come after generated files
        'Manifest',

        # Before release
        [ 'Git::Check' => { changelog => 'CHANGES', allow_dirty => 'README' } ],
        [ 'CheckChangesHasContent' => { changelog => 'CHANGES' } ],
        'TestRelease',
        'CheckExtraTests',
        'ConfirmRelease',

        # Release
        ( $self->fake_release ? 'FakeRelease' : 'UploadToCPAN' ),

        # After release
        [ 'GithubUpdate' => { cpan => 1, p3rl => 1 } ],
        'CopyReadmeFromBuild',
        'CopyMakefilePLFromBuild',
        'Git::Commit',
        [ 'Git::Tag' => { tag_format => $self->tag_format } ],
        'InstallRelease',
        [ 'NextRelease' => { filename => 'CHANGES', format => '%-9v %{yyyy-MM-dd}d' } ],
    );
    $self->add_plugins([ 'Twitter' => { hash_tags => '#perl #cpan', url_shortener => 'IsGd' } ])
        if ($self->twitter and not $self->fake_release);

    $self->add_bundle(
        'TestingMania' => {
            add  => $self->payload->{'add_tests'},
            skip => $self->payload->{'skip_tests'},
        },
    );
}

=head1 SEE ALSO

C<L<Dist::Zilla>>

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=begin Pod::Coverage

configure

=end Pod::Coverage
