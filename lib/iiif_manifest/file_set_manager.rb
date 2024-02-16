module IIIFManifest
  class FileSetManager

      attr_reader :work

      PRESENTER_TYPES = {
        'Mesh' => 'mesh',
        'CTImageSeries' => 'volume',
        'Image' => 'image',
        'Video' => 'video'
      }

      def initialize(work)
        @work = work
      end

      def file_set_presenters
        @file_set_presenters ||= work.file_set_presenters
      end

      def results
        return [] unless media_type = @work.media_type&.first

        type = "#{PRESENTER_TYPES[media_type]}?".to_sym # convert 'mesh' to :mesh?
        first_presenter(type).compact
      end

      def first_presenter(type)
        [file_set_presenters.find{ |presenter| presenter.try(type) }]
      end

      def all_presenters(type)
        file_set_presenters.select{ |presenter| presenter.try(type) }
      end

      def media_type_is?(type)
        work.media_type.first == type
      end

  end
end
