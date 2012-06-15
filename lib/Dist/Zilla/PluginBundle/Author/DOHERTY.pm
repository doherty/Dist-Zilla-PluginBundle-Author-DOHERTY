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
a L<Dist::Zilla> configuration that does what Mike wants.

=cut

# Dependencies
use autodie 2.00;
use Moose 0.99;
use Moose::Autobox;
use namespace::autoclean 0.09;
use Dist::Zilla 4.102341; # dzil authordeps
with 'Dist::Zilla::Role::PluginBundle::Easy';

=head1 USAGE

Just put C<[@Author::DOHERTY]> in your F<dist.ini>. You can supply the following
options:

=over 4

=item *

C<fake_release> specifies whether to use C<L<FakeRelease|Dist::Zilla::Plugin::FakeRelease>>
instead of C<< L<UploadToCPAN|Dist::Zilla::Plugin::UploadToCPAN> >>.

Default is false.

=item *

C<enable_tests> is a comma-separated list of testing plugins to add
to C<< L<TestingMania|Dist::Zilla::PluginBundle::TestingMania> >>.

Default is none.

=item *

C<disable_tests> is a comma-separated list of testing plugins to skip in
C<< L<TestingMania|Dist::Zilla::PluginBundle::TestingMania> >>.

Default is none.

=item *

C<tag_format> specifies how a git release tag should be named. This is
passed to C<< L<Git::Tag|Dist::Zilla::Plugin::Git::Tag> >>.

Default is C< %v%t >.

=item *

C<version_regexp> specifies a regexp to find the version number part of
a git release tag. This is passed to
C<< L<Git::NextVersion|Dist::Zilla::Plugin::Git::NextVersion> >>.

Default is C<< ^(v.+)$ >>.

=item *

C<twitter> says whether releases of this module should be tweeted.

Default is true.

=item *

C<surgical> says to use L<Dist::Zilla::Plugin::SurgicalPodWeaver>.

Default is false.

=item *

C<changelog> is the filename of the changelog.

Default is F<Changes>.

=item *

C<push_to> is the git remote to push to; can be specified multiple times.

Default is C<origin>.

=item *

C<github> is a boolean specifying whether to use the plugins
L<Dist::Zilla::Plugin::GitHub::Meta> and L<Dist::Zilla::Plugin::GitHub::Update>.

=back

=cut

sub mvp_multivalue_args { qw(push_to) }

sub configure {
    my $self = shift;

    my $conf = do {
        my $defaults = {
            changelog       => 'Changes',
            twitter         => 1,
            version_regexp  => '^v?(.+)$',
            tag_format      => 'v%v%t',
            fake_release    => 0,
            surgical        => 0,
            push_to         => [qw(origin)],
            github          => 1,
        };
        my $config = $self->config_slice(
            'version_regexp',
            'tag_format',
            'changelog',
            'fake_release',
            'twitter',
            'surgical',
            'critic_config',
            'push_to',
            'github',
            { enable_tests  => 'enable'  },
            { disable_tests => 'disable' },
        );
        $defaults->merge($config);
    };
    my @dzil_files_for_scm = qw(Makefile.PL Build.PL README README.mkdn);

    $self->add_plugins(
        # Version number
        [ 'Git::NextVersion' => { version_regexp => $conf->{version_regexp} } ],
        'OurPkgVersion',
        'Git::Describe',

        # Gather & prune
        'GatherDir',
        [ 'PruneFiles' => { filenames => [@dzil_files_for_scm] } ], # Required by CopyFilesFromBuild
        'PruneCruft',
        'ManifestSkip',

        # Generate dist files & metadata
        'ReadmeFromPod',
        'ReadmeMarkdownFromPod',
        'License',
        'MinimumPerl',
        'AutoPrereqs',
        ( $conf->{github} ? 'GitHub::Meta' : () ),
        'MetaJSON',
        'MetaYAML',
        [ 'MetaNoIndex' => { dir => [qw(corpus)] } ],

        # File munging
        ( $conf->{surgical}
            ? [ 'SurgicalPodWeaver' => { config_plugin => '@Author::DOHERTY' } ]
            : [ 'PodWeaver'         => { config_plugin => '@Author::DOHERTY' } ]
        ),

        # Build system
        'ExecDir',
        'ShareDir',
        'MakeMaker',
        'ModuleBuild',

        # Manifest stuff must come after generated files
        'Manifest',

        # Before release
        [ 'CheckChangesHasContent' => { changelog => $conf->{changelog} } ],
        [ 'Git::Check' => {
            changelog => $conf->{changelog},
            allow_dirty => ['dist.ini', $conf->{changelog}, @dzil_files_for_scm],
        } ],
        'TestRelease',
        'CheckExtraTests',
        'ConfirmRelease',

        # Release
        ( $conf->{fake_release}
            ? 'FakeRelease'
            : ('UploadToCPAN', 'SchwartzRatio')
        ),

        # After release
        [ 'CopyFilesFromBuild' => { copy => \@dzil_files_for_scm } ],
        [ 'NextRelease' => {
            filename => $conf->{changelog},
            format => '%-9v %{yyyy-MM-dd}d',
        } ],
        [ 'Git::Commit' => {
            allow_dirty => [$conf->{changelog}, @dzil_files_for_scm],
            commit_msg => 'Released %v%t',
        } ],
        [ 'Git::Tag' => {
            tag_format  => $conf->{tag_format},
            tag_message => "Released $conf->{tag_format}",
            signed      => 1,
        } ],
        [ 'Git::Push' => { push_to => $conf->{push_to} } ],
        ( $conf->{github} ? [ 'GitHub::Update' => { metacpan => 1 } ] : () ),
    );
    $self->add_plugins([ 'Twitter' => {
            hash_tags => '#perl #cpan',
            url_shortener => 'Googl',
            tweet_url => 'https://metacpan.org/release/{{$AUTHOR_UC}}/{{$DIST}}-{{$VERSION}}/',
        } ]) if ($conf->{twitter} and not $conf->{fake_release});

    $self->add_bundle(
        'TestingMania' => {
            enable          => $conf->{enable},
            disable         => $conf->{disable},
            changelog       => $conf->{changelog},
            critic_config   => $conf->{critic_config},
        }
     );

    $self->add_plugins(
        'InstallRelease',
        'Clean',
    ) unless $conf->{fake_release};
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
