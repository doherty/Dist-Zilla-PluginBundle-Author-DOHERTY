
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Module::Build" => "0.3601",
    "Test::More" => 0
  },
  "configure_requires" => {
    "ExtUtils::MakeMaker" => "6.30",
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "configure Dist::Zilla like DOHERTY",
  "dist_author" => [
    "Mike Doherty <doherty\@cpan.org>"
  ],
  "dist_name" => "Dist-Zilla-PluginBundle-Author-DOHERTY",
  "dist_version" => "0.24",
  "license" => "perl",
  "module_name" => "Dist::Zilla::PluginBundle::Author::DOHERTY",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Dist::Zilla" => "4.102341",
    "Dist::Zilla::Plugin::CheckChangesHasContent" => 0,
    "Dist::Zilla::Plugin::CheckExtraTests" => 0,
    "Dist::Zilla::Plugin::Clean" => 0,
    "Dist::Zilla::Plugin::CopyFilesFromBuild" => 0,
    "Dist::Zilla::Plugin::Git::Check" => 0,
    "Dist::Zilla::Plugin::Git::Commit" => 0,
    "Dist::Zilla::Plugin::Git::NextVersion" => 0,
    "Dist::Zilla::Plugin::Git::Tag" => "1.112380",
    "Dist::Zilla::Plugin::GitHub" => "0.13",
    "Dist::Zilla::Plugin::InstallGuide" => 0,
    "Dist::Zilla::Plugin::InstallRelease" => "0.006",
    "Dist::Zilla::Plugin::MinimumPerl" => "1.003",
    "Dist::Zilla::Plugin::OurPkgVersion" => 0,
    "Dist::Zilla::Plugin::PodWeaver" => 0,
    "Dist::Zilla::Plugin::ReadmeFromPod" => 0,
    "Dist::Zilla::Plugin::SurgicalPodWeaver" => "0.0015",
    "Dist::Zilla::Plugin::Twitter" => "0.010",
    "Dist::Zilla::PluginBundle::TestingMania" => 0,
    "Dist::Zilla::Role::PluginBundle::Easy" => 0,
    "Moose" => "0.99",
    "Moose::Autobox" => 0,
    "Pod::Weaver::PluginBundle::Author::DOHERTY" => "0.004",
    "Pod::Weaver::Section::BugsAndLimitations" => "1.102670",
    "WWW::Shorten::Googl" => 0,
    "autodie" => "2.00",
    "namespace::autoclean" => "0.09",
    "perl" => "5.006",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
