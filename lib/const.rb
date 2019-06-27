# const.rb

def LOG type = :normal, msg
  case type
  when :normal
    STDOUT.printf " [:::::] #{msg}\n"
  when :error
    STDERR.printf " \e[1;31m[ERROR]\e[0m #{msg}\n"
  when :good
    STDOUT.printf " \e[0;32m[:OKAY]\e[0m #{msg}\n"
  when :info
    STDOUT.printf " \e[0;36m[:INFO]\e[0m #{msg}\n"
  when :save
    STDOUT.printf " \e[1;36m[:SAVE]\e[0m #{msg}\n"
  end
end

def FORMAT str
  return "```#{str}```"
end
