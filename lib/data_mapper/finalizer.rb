module DataMapper

  class Finalizer
    attr_reader :mapper_registry
    attr_reader :edge_builder
    attr_reader :mapper_builder
    attr_reader :mappers

    # @api public
    def self.run
      new(Mapper.descendants.select { |mapper| mapper.model }).run
    end

    # @api private
    def initialize(mappers)
      @mappers         = mappers
      @mapper_registry = Mapper.mapper_registry
      @edge_builder    = RelationRegistry::Builder
      @mapper_builder  = Mapper::Builder

      @base_relation_mappers = @mappers.select { |mapper| mapper.respond_to?(:relation_name) }
    end

    # @api private
    def run
      finalize_base_relation_mappers
      finalize_attribute_mappers
      finalize_relationship_mappers

      self
    end

    private

    # @api private
    def target_keys_for(model)
      relationships_for_target(model).map(&:target_key).uniq
    end

    # @api private
    def relationships_for_target(model)
      @base_relation_mappers.map { |mapper|
        relationships     = mapper.relationships.select { |relationship| relationship.target_model == model }
        names             = relationships.map(&:name)
        via_relationships = mapper.relationships.select { |relationship| names.include?(relationship.via) }

        relationships + via_relationships
      }.flatten
    end

    def finalize_base_relation_mappers
      @base_relation_mappers.each do |mapper|
        model = mapper.model

        next if mapper_registry[model]

        name     = mapper.relation.name
        relation = mapper.gateway_relation
        keys     = target_keys_for(model)
        aliases  = mapper.aliases.exclude(*keys)

        mapper.relations.new_node(name, relation, aliases)

        mapper.finalize
      end

      @base_relation_mappers.each do |mapper|
        mapper.relationships.each do |relationship|
          edge_builder.call(mapper.relations, mapper_registry, relationship)
        end
      end
    end

    def finalize_attribute_mappers
      mappers.each { |mapper| mapper.finalize_attributes }
    end

    def finalize_relationship_mappers
      @base_relation_mappers.map(&:relations).uniq.each do |relations|
        relations.connectors.each_value do |connector|
          model        = connector.source_model
          relationship = connector.relationship
          mapper_class = mapper_registry[model].class
          mapper       = mapper_builder.call(connector, mapper_class)

          mapper_registry.register(mapper, relationship)
        end
      end

      @base_relation_mappers.each do |mapper|
        mapper.relations.freeze unless mapper.relations.frozen?
      end
    end
  end # class Finalizer
end # module DataMapper
