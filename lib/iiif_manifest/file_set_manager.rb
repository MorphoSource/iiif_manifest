module IIIFManifest
  class FileSetManager

      attr_reader :work

      def initialize(work)
        @work = work
      end

      def file_set_presenters
        @file_set_presenters ||= work.file_set_presenters
      end

      def results
        # Return first file set presenter of matching mime types
        return first_presenter(:mesh?) if media_type_is?('Mesh')
        return first_presenter(:volume?) if media_type_is?('CTImageSeries')
        return first_presenter(:image?) if media_type_is?('Image')
        return first_presenter(:video?) if media_type_is?('Video')

        # Don't return any presenters if media type is photogrammetry or other
        []
      end

      def first_presenter(type)
        [file_set_presenters.find{ |presenter| presenter.send(type) }]
      end

      def all_presenters(type)
        file_set_presenters.select{ |presenter| presenter.send(type) }
      end

      def media_type_is?(type)
        work.media_type.first == type
      end

  end
end
