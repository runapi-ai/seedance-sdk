# frozen_string_literal: true

Dir.chdir(__dir__) do

  Gem::Specification.new do |spec|
    spec.name = "runapi-seedance"
    spec.version = "0.2.10"
    spec.metadata["runapi_slug"] = "seedance"
    spec.authors = ["RunAPI"]
    spec.email = ["contact@runapi.ai"]

    spec.summary = "Seedance Ruby SDK for RunAPI"
    spec.description = "The Seedance Ruby SDK is the language-specific package for Seedance on RunAPI. Use this package for video generation, animation, and video editing workflows when your application needs request bodies, task status lookup, and consistent RunAPI errors in Ruby."
    spec.homepage = "https://runapi.ai/models/seedance"
    spec.license = "Apache-2.0"
    spec.required_ruby_version = ">= 3.1.0"
    spec.metadata["homepage_uri"] = "https://runapi.ai/models/seedance"
    spec.metadata["documentation_uri"] = "https://github.com/runapi-ai/seedance-sdk/blob/main/ruby/README.md"
    spec.metadata["source_code_uri"] = "https://github.com/runapi-ai/seedance-sdk"
    spec.metadata["bug_tracker_uri"] = "https://github.com/runapi-ai/seedance-sdk/issues"
    spec.metadata["changelog_uri"] = "https://github.com/runapi-ai/seedance-sdk/blob/main/CHANGELOG.md"


    spec.files = Dir.glob("lib/**/*") + %w[LICENSE README.md]
    spec.extra_rdoc_files = ["README.md"]
        spec.require_paths = ["lib"]

    spec.add_dependency "runapi-core", "~> 0.2.14"
  end
end
