lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "keepit/version"

Gem::Specification.new do |spec|
  spec.name = "keepit"
  spec.version = Keepit::VERSION
  spec.authors = ["Michail Merkushin"]
  spec.email = ["merkushin.m.s@gmail.com"]
  spec.summary = "Classes for protection"
  spec.homepage = "https://github.com/abak-press/keepit"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "dry-configurable", '>= 0.7.0'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "mock_redis"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "test-unit"
end
