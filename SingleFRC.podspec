Pod::Spec.new do |spec|
  spec.name             = "SingleFRC"
  spec.version          = "1.0"
  spec.summary          = "Like NSFetchedResultsController but for a single managed object."
  spec.homepage         = "https://github.com/fastred/SingleFetchedResultController"
  spec.license          = "MIT"
  spec.author           = { "Arkadiusz Holko" => "fastred@fastred.org" }
  spec.social_media_url = "https://twitter.com/arekholko"
  spec.source           = { :git => "https://github.com/fastred/SingleFetchedResultController.git", :tag => spec.version.to_s }
  spec.frameworks = "CoreData"
  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.9"
  spec.source_files = "Framework/*.swift"
end

