require 'rack'
require 'json'

require 'tinker/player'

module Tinker
  class Handler
    def initialize(world)
      @world = world
    end

    def call(env)
      req = Rack::Request.new(env)
      res = Rack::Response.new

      if req.request_method == "GET"
        if req.path_info == "/favicon.ico"
          return [404, {"Content-Type" => "text/plain"}, "Not found"]
        else
          start_new_game(req, res)
        end
      else
        handle_transition(req, res)
      end

      res.finish
    end

    def start_new_game(req, res)
      player = Player.new(@world.initial_state)
      player.move_to(@world.starting_location)
      render_game(player, req, res)
    end

    def handle_transition(req, res)
      player = Player.new(req.POST["state"])
      action = req.POST["action"]

      if action == "go"
        handle_go(player, req, res)
      elsif action == "get"
        handle_get(player, req, res)
      elsif action == "drop"
        handle_drop(player, req, res)
      end
    end

    def handle_go(player, req, res)
      direction = req.POST["key"]

      location = @world.places[player.location]
      path = location.exits[direction]

      player.move_to(path.destination)
      render_game(player, req, res)
    end

    def handle_get(player, req, res)
      key = req.POST["key"]
      player.at(player.location)[:items].delete(key)
      player.inventory << key
      render_game(player, req, res)
    end

    def handle_drop(player, req, res)
      key = req.POST["key"]
      player.at(player.location)[:items] << key
      player.inventory.delete(key)
      render_game(player, req, res)
    end

    def do_action(label, action, key)
      "<a href=\"#\" onclick='doAction(#{action.to_json}, #{key.to_json})'>#{label}</a>"
    end

    JAVASCRIPT = <<-JS
      <script type="text/javascript">
        function doAction(action, key) {
          var form = document.getElementById('exec');
          var actionField = document.getElementById('action');
          var keyField = document.getElementById('key');

          actionField.value = action;
          keyField.value = key;

          form.submit();
        }
      </script>
    JS

    STYLES = <<-CSS
      <style type="text/css">
        body {
          text-align: center;
          background: #777;
        }

        #container {
          text-align: left;
          width: 600;
          margin: auto;
          border: 1px solid black;
          background: white;
        }

        #container h1 {
          padding: 5px 10px;
          background: #aaa;
          margin: 0;
          border-bottom: 2px solid black;
        }

        #container p {
          margin: 10px;
        }
      </style>
    CSS

    def render_game(player, req, res)
      location = @world.places[player.location]
      
      res.write "<html><head><title>#{location.name}</title>#{JAVASCRIPT}#{STYLES}</head>"
      res.write "<body><div id='container'>"
      res.write "<h1>#{location.name}</h1>"
      res.write "<p>#{location.description}</p>"

      if player.at(player.location)[:items].any?
        res.write "<p>The following things are here:</p>"
        res.write "<ul>"
        player.at(player.location)[:items].each do |key|
          item = @world.items[key]
          res.write "<li>#{item.name} (#{do_action('get this now', 'get', key)})</li>"
        end
        res.write "</ul>"
      end

      if location.exits.empty?
        res.write "<p>The end! <a href='/'>Click here to play again.</a></p>"
      else
        res.write "<p>You can go:</p>"
        res.write "<ul>"
        location.exits.keys.sort.each do |key|
          path = location.exits[key]
          next unless path.allows?(player)
          res.write "<li>#{do_action(path.direction, 'go', key)}</li>"
        end
        res.write "</ul>"

        if player.inventory.any?
          res.write "<hr />"
          res.write "<p>You are currently carrying:</p>"
          res.write "<ul>"
          player.inventory.each do |key|
            item = @world.items[key]
            res.write "<li>#{item.name} (#{do_action('drop this here', 'drop', key)})</li>"
          end
          res.write "</ul>"
        end
      end

      res.write "</div>" # container
      res.write "<form method='post' id='exec'><input type='hidden' name='action' id='action' /><input type='hidden' name='key' id='key' /><input type='hidden' name='state' value='#{player.dump}' /></form>"
      res.write "</body></html>"
    end
  end
end
