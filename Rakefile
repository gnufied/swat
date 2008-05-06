require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'fileutils'

def __DIR__
  File.dirname(__FILE__)
end
include FileUtils

NAME = "swat"
$LOAD_PATH.unshift __DIR__+'/lib'
require 'swat'

CLEAN.include ['**/.*.sw?', '*.gem', '.config']

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = Swat::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = false
  s.summary = "Swat, A application for managing your todos"
  s.description = s.summary
  s.author = "Hemant Kumar"
  s.email = 'mail@gnufied.org'
  s.homepage = "http://packet.googlecode.com/svn/branches/swat"
  s.required_ruby_version = ">= 1.8.5"
  s.files = %w(LICENSE README TODO) + Dir.glob("{bin,tests,lib,ext,resources}/**/*")
  s.extensions = "ext/extconf.rb"
  s.require_path = "lib"
  s.require_path += "ext"
  s.bindir = "bin"
  s.executables = "swat"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
end

task :build do
  system("cd ext;ruby extconf.rb;make")
end

task :clean do
  %w(o so).each { |pattern| FileUtils.rm_r Dir.glob("ext/*.#{pattern}")}
end
