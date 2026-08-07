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
          # Camera annotations (painted into the scene alongside content, referenced by commenting annotations via scope)
          attach_cameras if display_cameras
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
          path = "#{parent.manifest_url}/#{container_type.downcase}/#{record.id}"
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

          def display_cameras
            Array.wrap(record.display_cameras) if ( record.respond_to?(:display_cameras) && record.display_cameras.present? )
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
            comments = Array.wrap(record.display_comments).map do |comment|
              # Add container ID to comment's SpecificResource target
              attach_target_id(comment)
            end

            comments_annotation_page = iiif_annotation_page_factory.new
            comments_annotation_page['id'] = "#{path}/annotation_page/#{comments_annotation_page.index}"
            comments_annotation_page.items = comments
            container.annotations = [comments_annotation_page]
          end

          # Camera annotations are painted into the same annotation page as content
          def attach_cameras
            cameras = Array.wrap(record.display_cameras).map do |camera|
              attach_target_id(camera)
            end

            annotation_page.items += cameras
          end

          # For content resources (including SpecificResource), add container ID to target
          def attach_target_id(content_resource)
            return content_resource unless content_resource.is_a?(Hash)

            if (
              content_resource.dig('target', 'type') == 'SpecificResource' &&
              content_resource.dig('target', 'source').present?
            )
              source = content_resource['target']['source']
              # source is a single JSON object per the Presentation 4 spec, but preserve
              # array shape if a caller supplied one rather than silently wrapping it.
              content_resource['target']['source'] = if source.is_a?(Array)
                source.map { |s| s.is_a?(Hash) ? attach_container_or_annotation_id(s) : s }
              else
                source.is_a?(Hash) ? attach_container_or_annotation_id(source) : source
              end
            elsif content_resource.dig('target')
              content_resource['target'] = attach_container_or_annotation_id(content_resource['target'])
            end

            content_resource
          end

          def attach_container_or_annotation_id(hash_like)
            if hash_like && hash_like['type'] == container_type && hash_like['id'].blank?
              # Attach ID of current container
              hash_like['id'] = container['id']
            else hash_like && hash_like['type'] == 'Annotation' && hash_like['id'].blank?
              # Attach ID of current annotation page's first painting annotation
              hash_like['id'] = annotation_page&.items&.first['id'] if annotation_page&.items.present?
            end
            hash_like
          end
      end
    end
  end
end