module IIIFManifest
  module V4
    class DisplayContent
      attr_reader :url, :width, :height, :duration, :iiif_endpoint, :format, :type, :label, :transform
      def initialize(url, type:, width: nil, height: nil, duration: nil, label: nil, format: nil, iiif_endpoint: nil, transform: nil)
        @url = url
        @type = type
        @width = width
        @height = height
        @duration = duration
        @label = label
        @format = format
        @iiif_endpoint = iiif_endpoint
        @transform = transform
      end

    end
  end
end