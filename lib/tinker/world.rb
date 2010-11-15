require 'tinker/place'
require 'tinker/item'

module Tinker
  class World
    attr_reader :places, :items, :initial_state, :starting_location

    def initialize
      @places = {}
      @items = {}
      @initial_state = {}
      @start = nil
    end

    def place(name, &block)
      place = Place.new(name)
      @places[name.downcase] = place
      place.instance_eval(&block)
      self
    end

    def item(name, options)
      location = options[:in] || options[:at]
      raise ArgumentError, "you need to tell me where the `#{name}' item is located, by using :at => '...' or :in => '..'" if location.nil?
        
      item_key = name.downcase
      location = location.downcase

      @items[item_key] = Item.new(name)
      @initial_state[location] ||= { :items => [] }
      @initial_state[location][:items] << item_key

      self
    end

    def start(options)
      location = options[:in] || options[:at]
      raise ArgumentError, "you need to tell me where to start, by using :at => '...' or :in => '..'" if location.nil?
      @starting_location = location.downcase
    end
  end
end
