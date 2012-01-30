Gem::Specification.new do |s|
  s.name        = 'xcli'
  s.version     = '0.0.2'
  s.summary     = "Xrono Command Line Client"
  s.description = "Xrono Command Line Client"
  s.authors     = ["Adam Gamble", "Ben Holley"]
  s.email       = ['adamgamble@gmail.com','ben@isotope11.com']
  s.files       = ["bin/xcli", "lib/xcli.rb", "lib/xcli/configuration.rb", "lib/xcli/cli.rb"]
  s.bindir      = "bin"
  s.executables = ['xcli']
  s.homepage    = 'http://rubygems.org/gems/example'

  s.add_dependency('thor',  "~> 0.14.0")
  s.add_dependency('command_line_reporter',  "~> 2.1")
  s.add_dependency('grit',  "~> 2.4.1")
  s.add_dependency('httparty',  "~> 0.8.1")
end
