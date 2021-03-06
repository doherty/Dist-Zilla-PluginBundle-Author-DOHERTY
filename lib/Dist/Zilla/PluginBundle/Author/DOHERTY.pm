package Dist::Zilla::PluginBundle::Author::DOHERTY;
use strict;
use warnings;
# ABSTRACT: configure Dist::Zilla like DOHERTY
# VERSION

=head1 SYNOPSIS

    # in dist.ini
    [@Author::DOHERTY]

=head1 DESCRIPTION

C<Dist::Zilla::PluginBundle::Author::DOHERTY> provides shorthand for
a L<Dist::Zilla> configuration that does what Mike wants.

=cut

use feature qw(say);
use Getopt::Long;
use List::MoreUtils qw(any);

use Moose 0.99;
with 'Dist::Zilla::Role::PluginBundle::Easy';

use Moose::Autobox;
use Moose::Util::TypeConstraints;
use namespace::autoclean 0.09;

=head1 USAGE

Just put C<[@Author::DOHERTY]> in your F<dist.ini>. You can supply the following
options:

=over 4

=item *

C<custom_build> specifies to use L<Dist::Zilla::Plugin::ModuleBuild::Custom>
instead of generating boilerplate L<ExtUtils::MakeMaker> and L<Module::Build>
build tools.

=cut

has custom_build => (
    is => 'rw',
    isa => 'Bool',
    lazy => 1,
    default => sub { $_[0]->payload->{custom_build} // 0 },
);

=item *

C<fake_release> specifies whether to use C<L<FakeRelease|Dist::Zilla::Plugin::FakeRelease>>
instead of C<< L<UploadToCPAN|Dist::Zilla::Plugin::UploadToCPAN> >>.

Default is false.

=cut

has fake_release => (
    is  => 'rw',
    isa => 'Bool',
    lazy => 1,
    default => sub { $_[0]->payload->{fake_release} // 0 },
);

=item *

C<enable_tests> is a comma-separated list of testing plugins to add
to C<< L<TestingMania|Dist::Zilla::PluginBundle::TestingMania> >>.

Default is none.

=cut

has enable_tests => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub { $_[0]->payload->{enable_tests} // [] },
);

=item *

C<disable_tests> is a comma-separated list of testing plugins to skip in
C<< L<TestingMania|Dist::Zilla::PluginBundle::TestingMania> >>.

Default is none.

=cut

has disable_tests => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub { $_[0]->payload->{disable_tests} // [] },
);

=item *

C<tag_format> specifies how a git release tag should be named. This is
passed to C<< L<Git::Tag|Dist::Zilla::Plugin::Git::Tag> >>.

Default is C< %v%t >.

=cut

has tag_format => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { $_[0]->payload->{tag_format} // 'v%v%t' },
);

=item *

C<version_regexp> specifies a regexp to find the version number part of
a git release tag. This is passed to
C<< L<Git::NextVersion|Dist::Zilla::Plugin::Git::NextVersion> >>.

Default is C<< ^(v.+)$ >>.

=cut

has version_regexp => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { $_[0]->payload->{version_regexp} // '^v?([\d.]+)(?:-TRIAL)?$' },
);

=item *

C<twitter> says whether releases of this module should be tweeted.

Default is true.

=cut

has twitter => (
    is => 'ro',
    isa => 'Bool',
    lazy => 1,
    default => sub { $_[0]->payload->{twitter} // 1 },
);

=item *

C<surgical> says to use L<Dist::Zilla::Plugin::SurgicalPodWeaver>.

Default is false.

=cut

has surgical => (
    is => 'ro',
    isa => 'Bool',
    lazy => 1,
    default => sub { $_[0]->payload->{surgical} // 0 },
);

=item *

C<max_target_perl> is the highest minimum version of perl you intend to require.
This is passed to L<Dist::Zilla::Plugin::Test::MinimumVersion>, which generates
a F<minimum-version.t> test that'll warn you if you accidentally used features
from a higher version of perl than you wanted. (Having a lower required version
of perl is okay.)

=cut

has max_target_perl => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { $_[0]->payload->{max_target_perl} // '5.10.1' },
);

=item *

C<changelog> is the filename of the changelog.

Default is F<Changes>.

=cut

has changelog => (
    is  => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { $_[0]->payload->{changelog} // 'Changes' },
);

=item *

C<push_to> is the git remote to push to; can be specified multiple times.

Default is C<origin>.

=cut

has push_to => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub { $_[0]->payload->{push_to} // [qw(origin)] },
);

=item *

C<github> is a boolean specifying whether to use the plugins
L<Dist::Zilla::Plugin::GitHub::Meta> and L<Dist::Zilla::Plugin::GitHub::Update>.

=cut

has github => (
    is  => 'ro',
    isa => 'Bool',
    lazy => 1,
    default => sub { $_[0]->payload->{github} // 1 },
);

=item *

C<critic_config> is a filename to pass through to L<Dist::Zilla::Plugin::Test::Perl::Critic>.

=cut

has critic_config => (
    is => 'ro',
    isa => 'Str',
);

=item *

C<fork_is_authoritative> tells L<GitHub::Meta|Dist::Zilla::Plugin::GitHub::Meta>
that your fork is authoritative. That means that the repository, issues, etc
will point to your stuff on github, instead of wherever you forked from. This
is useful if your repository on Github is a fork, but you have taken over
maintaining the module, so people should probably send bug reports to you
instead of the original author, and should fork from your repo, etc.

=cut

has fork_is_authoritative => (
    is  => 'ro',
    isa => 'Bool',
    lazy => 1,
    default => sub { $_[0]->payload->{fork_is_authoritative} // 0 },
);

=item *

C<github_metadata_remote> tells L<GitHub::Meta|Dist::Zilla::Plugin::GitHub::Meta>
that this is the Github repository from which to take metadata. This can be freely
combined with C<fork_is_authoritative> to control whether we "follow the symlink"
if the repo this points to is a fork. By default, the repo will be extracted from
the url for the C<origin> remote.

=cut

has github_metadata_remote => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { $_[0]->payload->{github_metadata_remote} // 'origin' },
);

=item *

C<release_to> is a string that specifies where to send the release. Valid release
targets are:

=over 4

=item * PAUSE (or CPAN)

We'll use L<UploadToPAUSE|Dist::Zilla::Plugin::UploadToCPAN> to do the release,
and clean up afterwards. This is the default

=item * local

We will do all the releasey things like tagging and pushing and whatnot, but
we won't do any releasing things, and we won't clean up. This leaves the release
tarball sitting there for you to do with as you will.

=back

In the future, there might be an option to scp the tarball somewhere.


=item *

C<has_version> and C<strict_version> set options in L<Dist::Zilla::PluginBundle::TestingMania>,
which passes them along to L<Dist::Zilla::Plugin::Test::Version> and thus
L<Test::Version>. They set C<has_version> and C<is_strict> respectively.

=cut

has has_version => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { $_[0]->payload->{has_version} // 1 },
);

has strict_version => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { $_[0]->payload->{strict_version} // 0 },
);

=item *

C<sharedir> indicates which directory is your dist's share directory. The
default is F<share>.

=cut

has sharedir => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { $_[0]->payload->{sharedir} // '' },
);

=back

=cut

enum 'ReleaseTarget', [qw( CPAN PAUSE local )];

has release_to => (
    is  => 'rw',
    isa => 'ArrayRef[ReleaseTarget]',
    lazy => 1,
    default => sub { $_[0]->payload->{release_to} // [qw/PAUSE/] },
);

has weaver_config => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => '@Author::DOHERTY',
);

has dzil_files_for_scm => (
    is  => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub {
        my $self = shift;
        return [
            (qw/ Makefile.PL /)x!$self->custom_build,
            qw/ README.mkdn /,
        ];
    },
);

has noindex_dirs => (
    is  => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub { $_[0]->payload->{noindex_dirs} // [qw(corpus inc examples)] },
);


sub mvp_multivalue_args { qw(push_to release_to disable_tests enable_tests) }

sub configure {
    my $self = shift;

=head1 COMMAND LINE OPTIONS

=over 4

=item C<--fake-release>

Do a fake release.

=item C<--release-to>

Specify release targets - can be specified multiple times.

=item C<--offline>

Don't do things that need a network connection: sets C<github> and C<twitter>
to false; sets C<push_to> to an empty array ref (ie: don't push anywhere);
and sets C<release_to> to local.

=back

=head1 ENVIRONMENT

=over 4

=item * C<NO_TEST>

If true, doesn't add L<TestRelease|Dist::Zilla::Plugin::TestRelease> or
L<CheckExtraTests|Dist::Zilla::Plugin::CheckExtraTests>.

=back

=cut

    {
        my %opts;
        GetOptions( \%opts,
            'fake-release|fake!',
            'release-to=s@',
            'offline!',
        );
        $self->fake_release($opts{'fake-release'}) if $opts{'fake-release'};
        $self->release_to($opts{'release-to'}) if $opts{'release-to'};

        if ($opts{offline}) {
            $self->github(0);
            $self->release_to([qw/local/]);
            $self->push_to([]);
            $self->twitter(0);
        }
    }

    $self->add_plugins(
        # Version number
        [ 'Git::NextVersion' => { version_regexp => $self->version_regexp } ],
        'OurPkgVersion',
    );

    $self->add_plugins(
        # Gather & prune
        [ 'GatherDir' => {
            exclude_filename => [
                @{$self->dzil_files_for_scm},           # Required by CopyFilesFromBuild
                (qw/ MANIFEST /)x!$self->custom_build,  # Required by CustomBuild
            ]
        }],
        ( $self->sharedir
            ? [ 'ShareDir' => { dir => $self->sharedir } ]
            : 'ShareDir'
        ),
        'PruneCruft',
        'ManifestSkip',
    );

    $self->add_plugins(
        # File munging
        ( $self->surgical
            ? [ 'SurgicalPodWeaver' => { config_plugin => $self->weaver_config } ]
            : [ 'PodWeaver'         => { config_plugin => $self->weaver_config } ]
        ),
    );

    my %github_meta_settings;
    $github_meta_settings{fork} = 0 if $self->fork_is_authoritative;
    $github_meta_settings{remote} //= $self->github_metadata_remote;

    $self->add_plugins(
        # Generate dist files & metadata
        'ReadmeFromPod',
        'ReadmeMarkdownFromPod',
        'License',
        'InstallGuide',
        'MinimumPerl',
        'AutoPrereqs',
        [ 'GitHub::Meta' => \%github_meta_settings ],
        'MetaJSON',
        'MetaYAML',
        [ 'MetaNoIndex' => { dir => $self->noindex_dirs } ],
    );

    $self->add_plugins(
        # Build system
        'ExecDir',
        ( $self->custom_build
            ? 'ModuleBuild::Custom'
            : 'MakeMaker'
        ),
    );

    # Manifest stuff must come after generated files
    $self->add_plugins('Manifest');

    $self->add_plugins(
        # Before release
        # 'Git::CheckFor::CorrectBranch',
        # 'Git::CheckFor::Fixups',
        [ 'CheckChangesHasContent' => { changelog => $self->changelog } ],
        [ 'Git::Check' => {
            changelog => $self->changelog,
            allow_dirty => ['dist.ini', $self->changelog, @{ $self->dzil_files_for_scm }],
        } ],
        ($ENV{NO_TEST} ? () : qw(TestRelease CheckExtraTests)),
        'ConfirmRelease',
    );

    # Releasers
    if ($self->fake_release) {
        $self->add_plugins('FakeRelease');
    }
    else {
        if ( any { $_ =~ m/^local$/i } @{ $self->release_to } ) {
            $self->add_plugins('FakeRelease');
            say STDERR '[@Author::DOHERTY] Releasing locally';
        }
        if ( any { $_ =~ m/^(?:CPAN|PAUSE)$/i } @{ $self->release_to } ) {
            $self->add_plugins('UploadToCPAN', 'SchwartzRatio');
            say STDERR '[@Author::DOHERTY] Releasing to CPAN';
        }
    }

    $self->add_plugins(
        # After release
        [ 'CopyFilesFromBuild' => { copy => $self->dzil_files_for_scm } ],
        [ 'NextRelease' => {
            filename => $self->changelog,
            format => '%-9v %{yyyy-MM-dd}d',
        } ],
        [ 'Git::Commit' => {
            allow_dirty => [$self->changelog, @{ $self->dzil_files_for_scm }],
            commit_msg => 'Released %v%t',
        } ],
        [ 'Git::Tag' => {
            tag_format  => $self->tag_format,
            tag_message => "Released @{[ $self->tag_format ]}",
            signed      => 1,
        } ],
        [ 'Git::Push' => { push_to => $self->push_to } ],
        ( $self->github ? [ 'GitHub::Update' => { metacpan => 1 } ] : () ),
    );

    $self->add_plugins([ 'Twitter' => {
            hash_tags => '#perl #cpan',
            url_shortener => 'Googl',
            tweet_url => 'https://metacpan.org/release/{{$AUTHOR_UC}}/{{$DIST}}-{{$VERSION}}/',
        } ]) if ($self->twitter and not $self->fake_release);

    $self->add_bundle(
        'TestingMania' => {
            enable          => $self->enable_tests,
            disable         => $self->disable_tests,
            changelog       => $self->changelog,
            has_version     => $self->has_version,
            strict_version  => $self->strict_version,
            max_target_perl => $self->max_target_perl,
            (critic_config  => $self->critic_config)x!!$self->critic_config,
        }
     );

    $self->add_plugins('InstallRelease')
        unless $self->fake_release;

    $self->add_plugins('Clean')
        unless any { $_ eq 'local' } @{ $self->release_to };
}

=head1 SEE ALSO

C<L<Dist::Zilla>>

=cut

__PACKAGE__->meta->make_immutable;

1;

=begin Pod::Coverage

configure

mvp_multivalue_args

=end Pod::Coverage
