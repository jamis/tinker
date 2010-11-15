module Tinker
  class Exit
    attr_reader :direction, :destination, :options

    def initialize(direction, destination, options)
      @direction = direction
      @destination = destination.strip.downcase
      @options = options
    end

    def allows?(player)
      if options[:with]
        player.inventory.include?(options[:with].downcase.strip)
      elsif options[:without]
        !player.inventory.include?(options[:without].downcase.strip)
      else
        true
      end
    end
  end
end
