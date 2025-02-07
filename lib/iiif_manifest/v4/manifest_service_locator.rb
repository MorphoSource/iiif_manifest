module IIIFManifest
  module V4
    class ManifestServiceLocator < IIIFManifest::V3::ManifestServiceLocator
      class << self
        # Builders which receive a work as an argument to .new and return objects
        #   that respond to #apply.
        
        # Constructs manifest properties, including items array, and adds container(s) (canvas, scene, todo timeline)
        def record_property_builder
          IIIFManifest::ManifestServiceLocator::InjectedFactory.new(
            IIIFManifest::V3::ManifestBuilder::RecordPropertyBuilder,
            iiif_search_service_factory: iiif_search_service_factory,
            iiif_autocomplete_service_factory: iiif_autocomplete_service_factory,
            canvas_builder_factory: container_builder_factory
          )
        end

        # Factory that delivers canvas or scene builder depending on work.container_type
        def container_builder_factory
          ManifestBuilder::ContainerBuilderFactory.new(
            composite_builder: composite_builder,
            canvas_builder_factory: canvas_builder,
            scene_builder_factory: scene_builder
          )
        end

        def scene_builder
          IIIFManifest::ManifestServiceLocator::InjectedFactory.new(
            ManifestBuilder::SceneBuilder,
            iiif_scene_factory: iiif_scene_factory,
            content_builder: content_builder,
            choice_builder: choice_builder,
            iiif_annotation_page_factory: iiif_annotation_page_factory
          )
        end

        def iiif_scene_factory
          IIIFManifest::V4::ManifestBuilder::IIIFManifest::Scene
        end
      end
    end
  end
end