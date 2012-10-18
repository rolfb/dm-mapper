module DataMapper
  class RelationRegistry
    class RelationNode < Graph::Node

      # Relation node wrapping arel relation
      #
      class ArelRelation < self
        include Enumerable

        def each(&block)
          return to_enum unless block_given?
          relation.each do |row|
            yield(row.symbolize_keys!)
          end
          self
        end

        def rename(new_aliases)
          raise NotImplementedError
        end

        def join(other)
          raise NotImplementedError
        end

        def header
          raise NotImplementedError
        end

        def restrict(*args, &block)
          raise NotImplementedError
        end

        def sort_by(&block)
          raise NotImplementedError
        end

        def aliased_for(relationship)
          raise NotImplementedError
        end

        def aliases_for(relationship)
          raise NotImplementedError
        end

        def clone_for(relationship, aliases = nil)
          raise NotImplementedError
        end

        def relation_for_join(relationship)
          raise NotImplementedError
        end

      end # class ArelRelation

    end # class RelationNode
  end # class RelationRegistry
end # module DataMapper
