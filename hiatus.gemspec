require_relative 'lib/hiatus/version'

Gem::Specification.new do |spec|
  spec.name          = "circuit-hiatus"
  spec.version       = Hiatus::VERSION
  spec.authors       = ["cesartalvez"]
  spec.email         = ["cesartalvez@gmail.com"]

  spec.summary       = %q{ Write a short summary, because RubyGems requires one.}
  spec.description   = %q{ Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/cesartalves/hiatus"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = " Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = " Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_development_dependency 'httparty'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'simplecov', '0.17.1'
end
