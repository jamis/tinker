require 'rake'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "A simple CYOA game system."
  s.name = 'tinker'
  s.version = "0.0.1"
  s.files = FileList["README.markdown", "Rakefile", "bin/*", "lib/**/*.rb", "spec/**/*.rb", "examples/**/*.tinker"].to_a
  s.executables << "tinker"
  s.description = "Tinker is a simple choose-your-own-adventure game system."
  s.author = "Jamis Buck"
  s.email = "jamis@jamisbuck.org"
  s.homepage = "http://github.com/jamis/tinker"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

