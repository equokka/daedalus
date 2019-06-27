# utils.rb

class Daedalus::Utils
  def save volume = nil
    File.open($system.userdata_filepath, "w") { |f| f.write $system.userdata.to_yaml }
    LOG :save, "Userdata saved!" unless volume == :quiet
  end

  def maintenance
    $system.seed["effects"].each_key do |l|
      $system.userdata["effects"][l] = {} if !$system.userdata["effects"].key? l
      $system.userdata["effects"][l]["afflicted"] = [] unless $system.userdata["effects"]["afflicted"]
      $system.userdata["effects"][l]["description"] = "" unless $system.userdata["effects"]["description"]
    end
    $system.seed["effects"].each do |e|
      # e = [key, val]
      # ie.  name, etc
      # glowing, [...]
      $system.userdata["effects"][e[0]]["description"] = e[1]["description"]
    end
  end

  def check_effect id, type
    unless $system.userdata["effects"].include? type
      LOG :error, "Tried to call Daedalus::Utils#check_effect with invalid type: #{type}"
      return
    end
    return $system.userdata["effects"][type]["afflicted"].include? id
  end
  def afflict id, type
    unless $system.userdata["effects"].include? type
      LOG :error, "Tried to call Daedalus::Utils#afflict with invalid type: #{type}"
      return
    end
    $system.userdata["effects"][type]["afflicted"] |= [id]
  end

  def store_message str
    @stored_messages = [] if @stored_messages.nil?
    @stored_messages.unshift str
  end
  def get_message
    @stored_messages = [] if @stored_messages.nil?
    @stored_messages.shift unless @stored_messages.empty?
  end
end
