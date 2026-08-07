module IIIFManifest
  module V4
    class ManifestBuilder
      # Expand from V3 BodyBuilder to support SpecificResource bodies
      class BodyBuilder < ::IIIFManifest::V3::ManifestBuilder::BodyBuilder
        private

          def build_body
            if display_content.respond_to?(:transform) && display_content.transform.present?
              # If the display content has a transform, we need to create a SpecificResource
              body['type'] = 'SpecificResource'
              body['source'] = apply_body_properties({})
              body['transform'] = display_content.transform
            else
              apply_body_properties(body)
            end
          end

          def apply_body_properties(hash_like)
            # Apply the properties of the body to the hash-like object
            hash_like['id'] = display_content.url
            hash_like['type'] = body_type
            hash_like['height'] = display_content.height if display_content.try(:height).present?
            hash_like['width'] = display_content.width if display_content.try(:width).present?
            hash_like['duration'] = display_content.duration if display_content.try(:duration).present?
            hash_like['format'] = display_content.format if display_content.try(:format).present?
            hash_like['label'] = ManifestBuilder.language_map(display_content.label) if display_content.try(:label).present?
            hash_like
          end
      end
    end
  end
end