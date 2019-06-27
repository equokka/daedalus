# daedalus.rb

SEED_FILE =     'seed.yaml'
CONFIG_FILE =   'discord_config.yaml'
USERDATA_FILE = 'userdata.yaml'

# Disable libsodium warning from discordrb
ENV['DISCORDRB_NONACL'] = ''

require 'discordrb'
require 'yaml'

require_relative 'lib/const'
require_relative 'lib/main'
require_relative 'lib/world'
require_relative 'lib/utils'
require_relative 'lib/gen'
require_relative 'lib/commands'
require_relative 'lib/reactions'

$system = Daedalus.new SEED_FILE, USERDATA_FILE, CONFIG_FILE
$system.load_world

$system.connect
$system.init
