gem 'hoe', '~> 3.0.7'
require 'hoe'
require 'fileutils'

Hoe.plugin :newgem

$hoe = Hoe.spec 'nnm_interval_calculator' do
  developer 'Kenichi Kamiya', 'kachick1+ruby@gmail.com'
  require_ruby_version '>= 1.9.3'
  dependency 'io-nosey', '~> 0.1.1', :runtime
  dependency 'time-unit', '~> 0.0.7', :runtime
  dependency 'yard', '>= 0.8.2.1', :development
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each {|t|load t}
