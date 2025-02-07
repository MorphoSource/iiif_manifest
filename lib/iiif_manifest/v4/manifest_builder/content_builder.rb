module IIIFManifest
  module V4
    class ManifestBuilder
      class ContentBuilder
        attr_reader :display_content, :iiif_annotation_factory, :body_builder_factory
        def initialize(display_content, iiif_annotation_factory:, body_builder_factory:)
          @display_content = display_content
          @iiif_annotation_factory = iiif_annotation_factory
          @body_builder_factory = body_builder_factory
          build_resource
        end

        def apply(container)
          annotation['target'] = container['id']

          # different container types have different required properties
          if container['type'] == 'Canvas'
            container['width'] = annotation.body['width']
            container['height'] = annotation.body['height']
            container['duration'] = annotation.body['duration'] if annotation.body['duration'].present?
          elsif container['type'] == 'Scene'
            container['duration'] = annotation.body['duration'] if annotation.body['duration'].present?
          elsif container['type'] == 'Timeline'
            container['duration'] = annotation.body['duration']
          end

          # Assume first item in container is an annotation page
          container.items.first.items += [annotation]
        end

        private

        def build_resource
          body_builder.apply(annotation)
        end

        def body_builder
          body_builder_factory.new(display_content)
        end

        def annotation
          @annotation ||= iiif_annotation_factory.new
        end
      end
    end
  end
end
