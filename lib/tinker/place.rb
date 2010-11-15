require 'tinker/exit'

module Tinker
  class Place
    attr_reader :name, :description, :exits

    def initialize(name)
      @name = name
      @exits = {}
    end

    def description(desc=nil)
      @description = desc if desc
      @description
    end

    def go(direction, *args, &block)
      if block_given? && args.empty?
        ExitParser.new(self, direction).instance_eval(&block)
      elsif !block_given? && (args.length == 1 || args.length == 2)
        destination = args[0]
        options = args[1] || {}
        @exits[direction.downcase] = Exit.new(direction, destination, options)
      else
        raise ArgumentError, "wrong use of `go' at `#{name}' with `#{direction}'"
      end
    end

    class ExitParser #:nodoc:
      def initialize(place, direction)
        @direction = direction
        @count = 0
        @place = place
      end

      def to(destination, options)
        if !options.key?(:with) && !options.key?(:without)
          raise ArgumentError, "`to' must have :with or :without to select the destination"
        end

        key = "#{@direction}-#{@count}"
        @place.exits[key] = Exit.new(@direction, destination, options)
        @count += 1
      end
    end
  end
end
