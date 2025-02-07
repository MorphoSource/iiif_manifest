module IIIFManifest
  module V4
    class ManifestBuilder
      ##
      # Factory for creating a DeepContainerBuilder
      class ContainerBuilderFactory
        attr_reader :composite_builder, :canvas_builder_factory, :scene_builder_factory

        # todo add timeline
        CONTAINER_TYPES = [:canvas, :scene].freeze

        def initialize(composite_builder:, canvas_builder_factory:, scene_builder_factory:)
          @composite_builder = composite_builder
          @canvas_builder_factory = canvas_builder_factory
          @scene_builder_factory = scene_builder_factory
        end

        def from(work)
          composite_builder.new(
            *file_set_presenters(work).map do |presenter|
              container_builder_factory_for(presenter).new(presenter, work)
            end
          )
        end

        private

        def container_builder_factory_for(presenter)
          case container_type(presenter)
          when :scene then scene_builder_factory
          else             canvas_builder_factory
          end
        end

        def container_type(presenter)
          if presenter.respond_to?(:container_type) && CONTAINER_TYPES.include?(presenter.container_type)
            presenter.container_type
          else
            :canvas
          end
        end

        def file_set_presenters(work)
          # Use FileSetManager to:
            # Omit file sets from child works
            # Limit file sets by format
          FileSetManager.new(work).results
        end
      end
    end
  end
end