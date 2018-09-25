# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-mysqlslowquerylog"
  gem.version       = "0.0.1"
  gem.authors       = ["Fadhel Ghorbel"]
  gem.email         = ["ext-fadhel.ghorbel@mister-auto.com"]
  gem.description   = %q{Fluentd plugin to concat MySQL slowquerylog.}
  gem.summary       = %q{Fluentd plugin to concat MySQL slowquerylog.}
  gem.homepage      = "http://gitlab.ma.lan/system_devteam/mysqlSlowQueries"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "fluentd", "~> 0.12"
  gem.add_development_dependency "rake", "~> 0"
  gem.add_development_dependency "test-unit", "~> 0"

  gem.add_runtime_dependency "fluentd", "~> 0.12"
end
