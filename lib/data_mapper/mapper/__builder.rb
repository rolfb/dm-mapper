module DataMapper
  class Mapper

    class Builder

      def self.build(connector)
        new(connector).build
      end

      def initialize(connector)
        @connector     = connector
        @source_model  = @connector.source_model
        @target_model  = @connector.target_model
        @source_mapper = DataMapper[@source_model].class

        @name = @connector.name
      end

      def build
        mapper_class.new(@connector.relation)
      end

      private

      def mapper_class
        klass = remap_fields(Mapper::Relation.from(@source_mapper, mapper_name))

        klass.map(@name, @target_model, target_model_attribute_options)

        if @connector.collection_target?
          klass.send(:include, Relationship::OneToMany::Iterator)
        end

        klass.finalize_attributes

        klass
      end

      def remap_fields(mapper)
        @connector.source_aliases.each do |name, field|
          if original = mapper.attributes.for_field(name)
            mapper.map(original.name, original.type, :key => original.key?, :to => field)
          end
        end

        mapper
      end

      def mapper_name
        "#{@source_model.name}_X_#{Inflector.camelize(@connector.name.to_s)}_Mapper"
      end

      def target_model_attribute_options
        {
          :collection => @connector.collection_target?,
          :aliases    => @connector.target_aliases
        }
      end
    end # class Builder
  end # class Mapper
end # module DataMapper