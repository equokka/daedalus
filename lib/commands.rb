# commands.rb

class Daedalus::Utils
  def create_commands
    $system.bot.command(:help) do |e|
      msg = "```asciidoc\n"
      msg << "Here are some common commands:\n"
      msg << "------------------------------\n"
      msg << "* [look], [l], [examine], [ex], [x]\n"
      msg << "* [take]\n"
      #msg << "* [use], eg. 'use x with y'\n"
      msg << "* [north], [up]\n"
      msg << "* [south], [down]\n"
      msg << "* [west], [left]\n"
      msg << "* [east], [right]\n"
      msg << "* ...and more. *experiment*!\n"
      msg << "```"
      e.respond msg
    end
    
    # important
    $system.bot.command(:eval) do |e, *code|
      break unless e.user.id == $system.discord_config["admin"]
      begin
        e.respond FORMAT(eval code.join(' '))
      rescue
        LOG :info, 'Error trying to eval:'
        LOG :info, code.join(' ')
      end
    end
    $system.bot.command(:stop) do |e|
      break unless e.user.id == $system.discord_config["admin"]
      $system.utils.save
      e.respond FORMAT('Ctesiphus saunters away.')
      exit
    end

    # movement
    $system.bot.command([:north, :up])   { |e| $system.bot.execute_command :go, e, ["north"] }
    $system.bot.command([:south, :down]) { |e| $system.bot.execute_command :go, e, ["south"] }
    $system.bot.command([:west, :left])  { |e| $system.bot.execute_command :go, e, ["west"]  }
    $system.bot.command([:east, :right]) { |e| $system.bot.execute_command :go, e, ["east"]  }
    $system.bot.command([:move, :go]) do |e, *target|
      target = [] if target.nil?
      if target.length == 0
        e.respond FORMAT("You jiggle rhythmically.")
      elsif target.length == 1
        target = target[0].downcase
        if ["north", "south", "west", "east", "up", "down", "left", "right"].include? target
          # convert to cardinal direction
          case target
          when "up"
            target = "north"
          when "down"
            target = "south"
          when "left"
            target = "west"
          when "right"
            target = "east"
          end
          # get symbol
          case target
          when "north"
            symbol = "🡹"
          when "south"
            symbol = "🡻"
          when "west"
            symbol = "🡸"
          when "east"
            symbol = "🡺"
          end
          if $system.world.can_move? e.user.id, target.to_sym
            $system.world.move e.user.id, target.to_sym
            e.respond FORMAT("#{symbol} You move #{target}ward...")
            e.respond $system.generate.describe_room($system.world.locate e.user.id)
          else
            e.respond FORMAT('There is nowhere to go in that direction.')
          end
        else
          e.respond FORMAT("You can't.")
        end
      end
    end

    # world
    $system.bot.command([:look, :examine, :ex, :x, :l]) do |e, *target|
      target = [] if target.nil?
      if target.length == 0
        # look at room
        e.respond $system.generate.describe_room($system.world.locate e.user.id)
      elsif target.length == 1
        target = target[0].downcase # no need to be doing target[0] constantly
        if ["north", "south", "west", "east", "up", "down", "left", "right"].include? target
          # look at a direction

          # convert to proper cardinal direction
          case target
          when "up"
            target = "north"
          when "down"
            target = "south"
          when "left"
            target = "west"
          when "right"
            target = "east"
          end

          if !$system.world.rooms[$system.world.locate e.user.id]["connections"][target].nil?
            # is there a room in that direction?
            e.respond FORMAT($system.world.rooms[$system.world.rooms[$system.world.locate e.user.id]["connections"][target]]["fardescription"])
          else
            e.respond FORMAT("There is nothing in that direction.")
          end
        elsif ["me", "self"].include? target
          # who are you?
          $system.bot.execute_command :whoami, e, []
        else
          # look at a feature of the room
          if $system.world.list_items($system.world.locate e.user.id).include? target
            e.respond $system.generate.describe_item target
          else
            # are they using a synonym?
            found = false
            $system.world.rooms[$system.world.locate e.user.id]["items"].each do |i|
              if $system.world.items[i]["synonyms"].include? target
                e.respond $system.generate.describe_item i
                found = true
              end
            end
            e.respond FORMAT("There is no such thing here.") unless found == true
          end
        end
      end
    end 

    # character
    $system.bot.command([:whoami, :me]) do |e|
      e.respond FORMAT('You look upon yourself...')
      $system.generate.mkchara e.user.id
      e.respond FORMAT($system.generate.describe e.user.id)
    end
    $system.bot.command(:newme) do |e|
      e.respond FORMAT("Through sheer force of will, you change shapes.")
      $system.generate.mkchara e.user.id, :force
      $system.utils.save
      e.respond FORMAT($system.generate.describe e.user.id)
    end

    # other
    $system.bot.command(:take) do |e, *target|
      target = [] if target.nil?
      if target.length == 0
        # command invoked by itself
        e.respond FORMAT("What are you trying to take?")
      elsif target.length == 1
        target = target[0].downcase
        # command invoked with 1-word argument
        if $system.world.rooms[$system.world.locate e.user.id]["items"].include?("pamphlet") && $system.world.items["pamphlet"]["synonyms"].include?(target)
          # there is a pamphlet where you are, and you asked for a synonym of pamphlet.
          $system.react :type => "take", :user => e.user.id, :item => "pamphlet", :room => ($system.world.locate e.user.id)
          e.respond $system.utils.get_message
        else
          # default to this.
          e.respond FORMAT('There is no such thing here.')
        end
      end
    end
    $system.bot.command(:pet) do |e, *target|
      target = [] if target.nil?
      if target.length == 0
        # command invoked by itself
        e.respond FORMAT("You wave your hand at the empty space uselessly.")
      elsif target.length == 1
        target = target[0].downcase
        # command invoked with 1-word argument
        if $system.world.rooms[$system.world.locate e.user.id]["items"].include?("ctesiphus") && $system.world.items["ctesiphus"]["synonyms"].include?(target)
          # ctesiphus is  where you are, and you asked for a synonym of ctesiphus.
          $system.react :type => "pet", :user => e.user.id, :item => "ctesiphus", :room => ($system.world.locate e.user.id)
          e.respond $system.utils.get_message
        else
          # default to this.
          e.respond FORMAT('There is no such thing to pet here... What are you doing?')
        end
      end
    end
    $system.bot.command(:read) do |e, *target|
      target = [] if target.nil?
      if target.length == 0
        # command invoked by itself
        e.respond FORMAT("You stare absentmindedly at somewhere far away.")
      elsif target.length == 1
        target = target[0].downcase
        # command invoked with 1-word argument
        if $system.world.rooms[$system.world.locate e.user.id]["items"].include?("pamphlet") && $system.world.items["pamphlet"]["synonyms"].include?(target)
          # there is a pamphlet where you are, and you asked for a synonym of pamphlet.
          $system.react :type => "read", :user => e.user.id, :item => "pamphlet", :room => ($system.world.locate e.user.id)
          e.respond $system.utils.get_message
        else
          # default to this.
          e.respond FORMAT('You can\'t read that right now.')
        end
      end
    end
  end
end
