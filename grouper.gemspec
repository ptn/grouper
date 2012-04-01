lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'grouper/version'

Gem::Specification.new do |s|
  s.name            = 'grouper'
  s.version         = Grouper::VERSION
  s.summary         = "An AI library that discovers groups in data"
  s.description     = "An AI library that discovers groups in data"
  s.authors         = ["Pablo Torres"]
  s.email           = 'tn.pablo@gmail.com'
  s.homepage        = 'http://github.com/ptn/grouper'

  s.files           = Dir.glob("{lib}/**/*")
  s.require_path    = 'lib'
end
