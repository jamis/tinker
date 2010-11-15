require 'rack'
require 'rack/showexceptions'

require 'tinker/handler'
require 'tinker/world'

module Tinker
  def self.play(file)
    world = World.new
    world.instance_eval(File.read(file), file, 1)

    puts "Please open your web browser and go to:"
    puts
    puts "  http://localhost:1414"
    puts

    Rack::Handler::WEBrick.run(
      Rack::ShowExceptions.new(
        Rack::Lint.new(
          Tinker::Handler.new(world))),
      :Port => 1414)
  end
end
