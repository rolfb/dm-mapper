module DataMapper
  class Mapper
    # Attribute
    #
    # @api private
    class Attribute
      include Equalizer.new(:name, :type, :field, :options)

      # @api private
      attr_reader :name

      # @api private
      attr_reader :type

      # @api private
      attr_reader :field

      # @api private
      attr_reader :options

      PRIMITIVES = [ String, Time, Integer, Float, BigDecimal, DateTime, Date, Class, TrueClass, Numeric, Object ].freeze

      # @api public
      def self.build(name, options = {})
        klass = if PRIMITIVES.include?(options[:type])
            Attribute::Primitive
          elsif options[:collection]
            Attribute::EmbeddedCollection
          else
            Attribute::EmbeddedValue
          end

        klass.new(name, options)
      end

      # @api private
      def initialize(name, options = {})
        @name    = name
        @field   = options.fetch(:to, @name)
        @key     = options.fetch(:key, false)
        @options = options.dup.freeze
      end

      # @api public
      def finalize
        # noop
      end

      # @api public
      def aliased_field(prefix)
        :"#{prefix}_#{field}"
      end

      # @api private
      #
      def load(tuple)
        raise NotImplementedError, "#{self.class} must implement #load"
      end

      # @api private
      def key?
        @key
      end

      # @api private
      def primitive?
        false
      end

      # @api private
      def clone(options = {})
        self.class.build(name, options.merge(:type => type))
      end

    end # class Attribute
  end # class Mapper
end # module DataMapper
