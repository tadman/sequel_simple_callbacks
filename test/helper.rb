require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sequel'
require 'sqlite3'

require 'sequel_simple_callbacks'

class Test::Unit::TestCase
end
