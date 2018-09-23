module IIIFManifest
  class DisplayMesh
    attr_reader :url, :iiif_endpoint, :format
    def initialize(url, format: nil)
      @url = url
      @format = format
    end
  end
end
