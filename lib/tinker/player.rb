module Tinker
  class Player
    def initialize(state)
      if state.is_a?(Hash)
        @state = Marshal.load(Marshal.dump(state)) # deep copy
      else
        @state = Marshal.load(state.unpack("m*").first)
      end

      @state[:self] ||= { :items => [] }
    end

    def dump
      [Marshal.dump(@state)].pack("m*").strip
    end

    def move_to(location)
      @state[:self][:at] = location
    end

    def at(location)
      @state[location.downcase.strip] ||= { :items => [] }
    end

    def location
      @state[:self][:at]
    end

    def inventory
      @state[:self][:items]
    end
  end
end
