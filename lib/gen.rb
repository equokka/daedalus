# gen.rb

class Daedalus::Gentools
  def mkchara id, forced = nil
    if !$system.userdata["users"].key?(id) || forced == :force
      $system.userdata["users"][id] = $system.seed["user_init"]
      $system.userdata["users"][id]["avatar"] = $system.generate.keywords
      $system.userdata["users"][id]["description"] = $system.generate.description id
      LOG :info, "Generated userdata for #{id}"
      $system.utils.save
    end
  end

  def keywords
    s = $system.seed["gen"]["avatar"]
    return {
      "species" => s["species"].sample,
      "descriptor" => s["descriptor"].sample,
      "eyes" => s["eyes"].sample,
      "height" => $system.generate.height,
      "preference" => s["preference"].sample
    }
  end

  def height # generate a height between 1.11m to 2.49m
    a = rand(1..2)
    a == 1 ? b = rand(1..9) : b = rand(1..4)
    c = rand(1..9)
    return "#{a}.#{b}#{c}".to_f
  end

  def description id
    k = $system.userdata["users"][id]["avatar"]
    str = ""
    str << "You are a #{k["descriptor"]} #{k["species"]}.\n"
    str << "You enjoy #{k["preference"]}. You are #{k["height"]}m and your eyes are #{k["eyes"]}."
    return str
  end

  def describe id
    str = ""
    str << $system.userdata["users"][id]["description"]
    $system.userdata["effects"].each do |e|
      if e[1]["afflicted"].include? id
        str << "\n"
        str << e[1]["description"]
      end
    end
    return str
  end

  def describe_room roomid
    str = ""
    room = $system.world.rooms[roomid]
    str << "```asciidoc\n"
    str << "== ╓#{"─"*(room["name"].length+2)}╖ ==\n"
    str << "== ║ #{       room["name"]      } ║ ==\n"
    str << "== ╙#{"─"*(room["name"].length+2)}╜ ==\n"
    str << room["description"]
    str << "```"
    return str
  end

  def describe_item itemid
    str = ""
    item = $system.world.items[itemid]
    str << "```asciidoc\n"
    str << "[#{item["symbol"]} ◆ #{item["name"]} ◆ #{item["symbol"]}]"
    str << "\n"
    str << item["description"]
    str << "\n"
    str << "```"
    return str
  end
end 
