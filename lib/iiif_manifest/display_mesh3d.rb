module IIIFManifest
  class DisplayMesh3D
    attr_reader :url, :iiif_endpoint, :format
    def initialize(url, format: nil, iiif_endpoint: nil)
      @url = url
      @format = format
      @iiif_endpoint = iiif_endpoint
    end
  end
end
