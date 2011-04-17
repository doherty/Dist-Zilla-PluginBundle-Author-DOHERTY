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
a L<Dist::Zilla> configuration approximately like:

    [Git::Check]
    [@Filter]
    -bundle = @Basic    ; Equivalent to using [@Basic]
    -remove = Readme    ; For use with [CopyReadmeFromBuild]
    -remove = ExtraTests

    [AutoPrereqs]
    [MinimumPerl]
    [Github::Meta]
    [PodWeaver]
    config_plugin = @Author::DOHERTY
    [InstallGuide]
    [ReadmeFromPod]
    [CopyReadmeFromBuild]
    [CopyMakefilePLFromBuild]

    [Git::NextVersion]
    [PkgVersion]
    [NextRelease]
    filename = Changes
    format   = %-9v %{yyyy-MM-dd}d
    [CheckChangesHasContent]
    changelog = Changes

    [Twitter]         ; config in ~/.netrc
    [Github::Update]  ; config in ~/.gitconfig
    [Git::Commit]
    [Git::Tag]

    [@TestingMania]
    changelog = Changes
    [LocalInstall]

=cut

# Dependencies
use autodie 2.00;
use Moose 0.99;
use Moose::Autobox;
use namespace::autoclean 0.09;

use Dist::Zilla 4.102341; # dzil authordeps
use Dist::Zilla::Plugin::CheckChangesHasContent         qw();
use Dist::Zilla::Plugin::CheckExtraTests                qw();
use Dist::Zilla::Plugin::CopyMakefilePLFromBuild 0.0017 qw(); # to run during AfterRelease
use Dist::Zilla::Plugin::CopyReadmeFromBuild     0.0017 qw(); # to run during AfterRelease
use Dist::Zilla::Plugin::Git::Check                     qw();
use Dist::Zilla::Plugin::Git::Commit                    qw();
use Dist::Zilla::Plugin::GitHub::Update            0.06 qw(); # Support for p3rl.org; new name
use Dist::Zilla::Plugin::GitHub::Meta              0.06 qw(); # new name
use Dist::Zilla::Plugin::Git::NextVersion               qw();
use Dist::Zilla::Plugin::Git::Tag                       qw();
use Dist::Zilla::Plugin::InstallGuide                   qw();
use Dist::Zilla::Plugin::InstallRelease           0.006 qw(); # to detect failed installs
use Dist::Zilla::Plugin::MinimumPerl                    qw();
use Dist::Zilla::Plugin::OurPkgVersion                  qw();
use Dist::Zilla::Plugin::PodWeaver                      qw();
use Dist::Zilla::Plugin::ReadmeFromPod                  qw();
use Dist::Zilla::Plugin::SurgicalPodWeaver       0.0015 qw(); # to avoid circular dependencies
use Dist::Zilla::Plugin::Twitter                  0.010 qw(); # Support for choosing WWW::Shorten::$site via WWW::Shorten::Simple
use Dist::Zilla::PluginBundle::TestingMania             qw(); # better deps tree & PodLinkTests; ChangesTests
use Pod::Weaver::PluginBundle::Author::DOHERTY    0.004 qw(); # new name
use Pod::Weaver::Section::BugsAndLimitations   1.102670 qw(); # to read from D::Z::P::Bugtracker
use WWW::Shorten::IsGd                                  qw(); # Shorten with WWW::Shorten::IsGd

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

C<add_tests> is a comma-separated list of testing plugins to add
to C<L<TestingMania|Dist::Zilla::PluginBundle::TestingMania>>.

=cut

has enable_tests => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => '',
);

=item *

C<skip_tests> is a comma-separated list of testing plugins to skip in
C<L<TestingMania|Dist::Zilla::PluginBundle::TestingMania>>.

=cut

has disable_tests => (
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
    default => sub { $_[0]->payload->{tag_format} || 'v%v' },
);

=item *

C<version_regex> specifies a regexp to find the version number part of
a git release tag. This is passed to C<L<Git::NextVersion|Dist::Zilla::Plugin::Git::NextVersion>>.

=cut

has version_regexp => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { $_[0]->payload->{version_regexp} || '^(?:v|release-)(.+)$' },
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

=item *

C<changelog> is the filename of the changelog, and defaults to F<Changes>.

=cut

has changelog => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { $_[0]->payload->{changelog} || 'Changes' },
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
        [ 'PruneFiles' => { filenames => ['Makefile.PL'] } ], # Required by CopyMakefilePLFromBuild
        'PruneCruft',
        'ManifestSkip',

        # Generate dist files & metadata
        'ReadmeFromPod',
        'License',
        'MinimumPerl',
        'AutoPrereqs',
        'GitHub::Meta',
        'MetaJSON',
        'MetaYAML',

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
        [ 'CheckChangesHasContent' => { changelog => $self->changelog } ],
        [ 'Git::Check' => {
            changelog => $self->changelog,
            allow_dirty => [$self->changelog, 'README', 'Makefile.PL'],
        } ],
        'TestRelease',
        'CheckExtraTests',
        'ConfirmRelease',

        # Release
        ( $self->fake_release ? 'FakeRelease' : 'UploadToCPAN' ),

        # After release
        'CopyReadmeFromBuild',
        'CopyMakefilePLFromBuild',
        [ 'NextRelease' => {
            filename => $self->changelog,
            format => '%-9v %{yyyy-MM-dd}d',
        } ],
        [ 'Git::Commit' => {
            allow_dirty => ['Makefile.PL', 'README', $self->changelog],
            commit_msg => 'Released %v%t',
        } ],
        [ 'Git::Tag' => { tag_format => $self->tag_format } ],
        'Git::Push',
        [ 'GitHub::Update' => { cpan => 0, p3rl => 1 } ],
    );
    $self->add_plugins([ 'Twitter' => { hash_tags => '#perl #cpan', url_shortener => 'IsGd' } ])
        if ($self->twitter and not $self->fake_release);

    $self->add_bundle(
        'TestingMania' => {
            enable  => $self->payload->{'enable_tests'},
            disable => $self->payload->{'disable_tests'},
            changelog => $self->changelog,
        },
    );

    $self->add_plugins(
        'InstallRelease',
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
