require 'iiif_manifest/version'
require 'active_support'
require 'active_support/core_ext/module'
require 'active_support/core_ext/object'

module IIIFManifest
  extend ActiveSupport::Autoload
  autoload :ManifestBuilder
  autoload :ManifestFactory
  autoload :ManifestServiceLocator
  autoload :DisplayImage
  autoload :DisplayMesh
  autoload :DisplayVolume
  autoload :IIIFCollection
  autoload :IIIFEndpoint
  autoload :V3

  # limit which file sets get included in the work manifest
  autoload :FileSetManager
end
