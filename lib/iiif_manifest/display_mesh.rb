module IIIFManifest
  class DisplayMesh
    attr_reader :url, :format, :type
    def initialize(url, format: nil, type: nil)
      @url = url
      @format = format
      @type = type
    end
  end
end
