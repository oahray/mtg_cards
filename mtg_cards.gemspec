require_relative 'lib/mtg_cards/version'

Gem::Specification.new do |spec|
  spec.name          = 'mtg_cards'
  spec.version       = MtgCards::VERSION
  spec.authors       = ['Oare Arene']
  spec.email         = ['oare@fliqpay.com']

  spec.summary       = "A gem that fetches cards from the MagicTheGathering API"
  spec.description   = "A rubygem that fetches cards from https://api.magicthegathering.io/v1/cards"
  spec.homepage      = 'https://github.com/oahray/mtg_cards'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/oahray/mtg_cards'
  spec.metadata['changelog_uri'] = 'https://github.com/oahray/mtg_cards'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Add dependencies
  spec.add_development_dependency 'pry'
end
