module DataMapper
  class RelationRegistry

    class RelationEdge < Graph::Edge

      def aliased_for(relationship, target_aliases)
        aliases = right.aliases_for(relationship).merge(target_aliases)
        self.class.new(relationship, left, right.clone(aliases))
      end

    end # class RelationEdge

  end # class RelationRegistry
end # module DataMapper
