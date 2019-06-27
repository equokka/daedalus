# main.rb

class Daedalus
  attr_accessor :utils, :userdata, :world
  attr_reader :seed, :generate, :discord_config, :bot, :userdata_filepath

  def initialize(seed_file, udata_file, discord_config_file)
    @utils    = Daedalus::Utils.new
    @generate = Daedalus::Gentools.new

    @userdata_filepath = udata_file

    begin
      @seed = YAML.load(IO.read(seed_file))
    rescue Exception => e
      LOG :error, "Failed to load #{seed_file}!"
      LOG :error, e.message
      raise e
    end

    if File.file?(udata_file)
      begin
        @userdata = YAML.load(IO.read(udata_file))
      rescue Exception => e
        LOG :error, "Exception while reading #{udata_file}:"
        LOG :error, e.message
        raise e
      end
    else
      LOG :info, "#{udata_file} does not exist!"
      LOG "Creating new #{udata_file}..."
      File.open(udata_file, "w") do |f|
        f.write(@seed["init"].to_yaml)
      end

      begin
        @userdata = YAML.load(IO.read(udata_file))
      rescue Exception => e
        LOG :error, "Exception while reading #{udata_file}:"
        LOG :error, e.message
        raise e
      end
    end
    LOG :good, "Userdata loaded!"

    begin
      @discord_config = YAML.load(IO.read(discord_config_file))
    rescue Exception => e
      LOG :error, "Exception while reading #{discord_config_file}:"
      LOG :error, e.message
      raise e
    end
    LOG :good, "Discord config loaded!"
  end

  def connect
    @bot = Discordrb::Commands::CommandBot.new(
      token:     @discord_config["token"],
      client_id: @discord_config["client_id"],
      prefix:    @discord_config["prefix"]
    )
    @utils.maintenance # make sure userdata makes sense
    @utils.save :quiet # preliminary save
  end

  def load_world
    @world = Daedalus::World.new @seed["world_file"]
  end

  def init
    @utils.create_commands
    @bot.run
  end
end
