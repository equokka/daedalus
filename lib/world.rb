# world.rb

class Daedalus::World
  attr_reader :rooms, :items

  def initialize world_file
    if $system.userdata["world"].empty?
      LOG :info, "World is empty -- populating from world file #{world_file}."
      begin
        world_seed = YAML.load(IO.read(world_file))
      rescue Exception => e
        LOG :error, "Failed to load #{world_file}!"
        LOG :error, e.message
        raise e
      end
      $system.userdata["world"] = world_seed
      LOG :good, "Loaded world into userdata."
    else
      LOG :info, "World found in userdata."
    end
    @rooms = $system.userdata["world"]["rooms"]
    @items = $system.userdata["world"]["items"]
  end

  def occupants roomid
    o = []
    $system.userdata["users"].each { |u| o << u["room"] }
    return o
  end

  def locate id
    $system.generate.mkchara id
    return $system.userdata["users"][id]["room"]
  end

  def move id, direction
    initial_room = $system.userdata["users"][id]["room"]
    $system.userdata["users"][id]["room"] = $system.world.rooms[$system.userdata["users"][id]["room"]]["connections"][direction.to_s]
    LOG :info, "#{id} has moved from room #{initial_room} (#{$system.world.rooms[initial_room]["name"]}) to #{$system.userdata["users"][id]["room"]} (#{$system.world.rooms[$system.userdata["users"][id]["room"]]["name"]})."
    $system.utils.save
  end

  def can_move? id, direction
    $system.generate.mkchara id
    $system.world.rooms[$system.userdata["users"][id]["room"]]["connections"][direction.to_s].nil? ? false : true
  end

  def list_items roomid
    $system.world.rooms[roomid]["items"]
  end
end
