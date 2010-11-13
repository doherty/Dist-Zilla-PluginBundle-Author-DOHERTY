use strict;
use warnings;
use diagnostics;

package Dist::Zilla::PluginBundle::DOHERTY;
# ABSTRACT: configure Dist::Zilla like DOHERTY
# ENCODING: utf-8

=head1 SYNOPSIS

    # in dist.ini
    [@DOHERTY]

=head1 DESCRIPTION

C<Dist::Zilla::PluginBundle::DOHERTY> provides shorthand for
a L<Dist::Zilla> configuration like:

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

    [Git::NextVersion]
    [PkgVersion]
    [NextRelease]
    filename = CHANGES
    format   = %-9v %{yyyy-MM-dd}d
    [CheckChangesHasContent]
    changelog = CHANGES

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
use Dist::Zilla::Plugin::Repository         0.13        qw(); # v2 Meta spec
use Dist::Zilla::Plugin::Bugtracker         1.102670    qw(); # to set bugtracker in dist.ini
use Dist::Zilla::Plugin::PodWeaver                      qw();
use Dist::Zilla::Plugin::InstallGuide                   qw();
use Dist::Zilla::Plugin::ReadmeFromPod                  qw();
use Dist::Zilla::Plugin::CopyReadmeFromBuild            qw();
use Dist::Zilla::Plugin::Git::NextVersion               qw();
use Dist::Zilla::Plugin::PkgVersion                     qw();
use Dist::Zilla::Plugin::NextRelease                    qw();
use Dist::Zilla::Plugin::CheckChangesHasContent         qw();
use Dist::Zilla::Plugin::Git::Commit                    qw();
use Dist::Zilla::Plugin::Git::Tag                       qw();
use Dist::Zilla::PluginBundle::TestingMania             qw();
use Dist::Zilla::Plugin::InstallRelease     0.002       qw();

use Pod::Weaver::Section::BugsAndLimitations 1.102670   qw(); # To read from D::Z::P::Bugtracker

with 'Dist::Zilla::Role::PluginBundle::Easy';

=head1 USAGE

Just put C<[@DOHERTY]> in your F<dist.ini>. You can supply the following
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
so the same interpolation rules apply. Defaults to C<http://github.com/doherty/%s/issues'>.

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

=back

=cut

sub configure {
    my $self = shift;

    $self->add_plugins(
        # Version number
        [ 'Git::NextVersion' => { version_regexp => $self->version_regexp } ],
        'PkgVersion',

        # Gather & prune
        'GatherDir',
        'PruneCruft',
        'ManifestSkip',

        # Generate dist files & metadata
        'ReadmeFromPod',
        'CopyReadmeFromBuild',
        'License',
        'MinimumPerl',
        'AutoPrereqs',
        'MetaYAML',
        'Repository',
        [ 'Bugtracker' => { web => $self->bugtracker } ],

        # File munging
        [ 'PodWeaver' => { config_plugin => '@DOHERTY' } ],

        # Build system
        'ExecDir',
        'ShareDir',
        'MakeMaker',

        # Manifest stuff must come after generated files
        'Manifest',

        # Before release
        'Git::Check',
        [ 'CheckChangesHasContent' => { changelog => 'CHANGES' } ],
        'TestRelease',
        'ConfirmRelease',

        # Release
        ( $self->fake_release ? 'FakeRelease' : 'UploadToCPAN' ),

        # After release
        'InstallRelease',
        'Git::Commit',
        [ 'Git::Tag' => { tag_format => $self->tag_format } ],
        [ 'NextRelease' => { filename => 'CHANGES', format => '%-9v %{yyyy-MM-dd}d' } ],
    );

    $self->add_bundle(
        'TestingMania' => {
            add => $self->add_tests,
            skip => $self->skip_tests,
        }
    );
}

=head1 SEE ALSO

C<L<Dist::Zilla>>

=cut

__PACKAGE__->meta->make_immutable;

1;

__END__

=begin Pod::Coverage

configure

=end Pod::Coverage
