
use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'configure Dist::Zilla like DOHERTY',
  'AUTHOR' => 'Mike Doherty <doherty@cpan.org>',
  'BUILD_REQUIRES' => {
    'File::Find' => '0',
    'File::Temp' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30',
    'Module::Build' => '0.3601'
  },
  'DISTNAME' => 'Dist-Zilla-PluginBundle-Author-DOHERTY',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Dist::Zilla::PluginBundle::Author::DOHERTY',
  'PREREQ_PM' => {
    'Dist::Zilla' => '4.102341',
    'Dist::Zilla::Plugin::CheckChangesHasContent' => '0',
    'Dist::Zilla::Plugin::CheckExtraTests' => '0',
    'Dist::Zilla::Plugin::Clean' => '0',
    'Dist::Zilla::Plugin::CopyFilesFromBuild' => '0',
    'Dist::Zilla::Plugin::Git::Check' => '0',
    'Dist::Zilla::Plugin::Git::Commit' => '0',
    'Dist::Zilla::Plugin::Git::NextVersion' => '0',
    'Dist::Zilla::Plugin::Git::Tag' => '0',
    'Dist::Zilla::Plugin::GitHub' => '0.13',
    'Dist::Zilla::Plugin::InstallGuide' => '0',
    'Dist::Zilla::Plugin::InstallRelease' => '0.006',
    'Dist::Zilla::Plugin::MinimumPerl' => '1.003',
    'Dist::Zilla::Plugin::OurPkgVersion' => '0',
    'Dist::Zilla::Plugin::PodWeaver' => '0',
    'Dist::Zilla::Plugin::ReadmeFromPod' => '0',
    'Dist::Zilla::Plugin::SurgicalPodWeaver' => '0.0015',
    'Dist::Zilla::Plugin::Twitter' => '0.010',
    'Dist::Zilla::PluginBundle::TestingMania' => '0.009',
    'Dist::Zilla::Role::PluginBundle::Easy' => '0',
    'Moose' => '0.99',
    'Moose::Autobox' => '0',
    'Pod::Weaver::PluginBundle::Author::DOHERTY' => '0.004',
    'Pod::Weaver::Section::BugsAndLimitations' => '1.102670',
    'WWW::Shorten::Googl' => '0',
    'WWW::Shorten::IsGd' => '0',
    'autodie' => '2.00',
    'namespace::autoclean' => '0.09'
  },
  'VERSION' => '0.021',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



