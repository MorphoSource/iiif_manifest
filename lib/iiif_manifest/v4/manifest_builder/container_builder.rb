module IIIFManifest
  module V4
    class ManifestBuilder
      # Builds IIIF V4 Container objects (e.g., Canvas or Scene)
      class ContainerBuilder
        attr_reader :record, :parent, :iiif_container_factory, :content_builder,
                    :choice_builder, :iiif_annotation_page_factory
        
                    def initialize(record,
                      parent,
                      iiif_container_factory:,
                      content_builder:,
                      choice_builder:,
                      iiif_annotation_page_factory:)
         @record = record
         @parent = parent
         @iiif_container_factory = iiif_container_factory
         @content_builder = content_builder
         @choice_builder = choice_builder
         @iiif_annotation_page_factory = iiif_annotation_page_factory
         apply_record_properties
         # Presentation 2.x approach
         attach_image if display_image
         # Presentation 3.0 approach
         attach_content if display_content
         # Commenting annotations
         attach_comments if display_comments
       end

       def container
         @container ||= iiif_container_factory.new
       end

       def container_type
        container['type'] || 'Canvas'
       end

       def path
         path = "#{parent.manifest_url}/#{container_type}/#{record.id}"
         path << "##{record.media_fragment}" if record.respond_to?(:media_fragment)
         path
       end

       def apply(items)
         return items if container.items.blank?
         items << container
       end

       private

          def display_image
            record.display_image if ( record.respond_to?(:display_image) && record.display_image.present? )
          end

          def display_content
            Array.wrap(record.display_content) if ( record.respond_to?(:display_content) && record.display_content.present? )
          end

          def display_comments
            Array.wrap(record.display_comments) if ( record.respond_to?(:display_comments) && record.display_comments.present? )
          end

          def apply_record_properties
            container['id'] = path
            container.label = ManifestBuilder.language_map(record.to_s) if record.to_s.present?
            annotation_page['id'] = "#{path}/annotation_page/#{annotation_page.index}"
            container.items = [annotation_page]
          end

          def annotation_page
            @annotation_page ||= iiif_annotation_page_factory.new
          end

          def attach_image
            content_builder.new(display_image).apply(container)
          end

          def attach_mesh
            content_builder.new(display_mesh).apply(container)
          end

          def attach_volume
            content_builder.new(display_volume).apply(container)
          end

          def attach_content
            if display_content.size == 1
              content_builder.new(display_content.first).apply(container)
            else
              choice_builder.new(display_content).apply(container)
            end
          end

          def attach_comments
            container.annotations = record.display_comments
          end
      end
    end
  end
end