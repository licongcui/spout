require 'test_helper'

class SpoutTest < Test::Unit::TestCase

  def test_spout_application
    assert_kind_of Module, Spout
  end

  def test_spout_version
    assert_kind_of String, Spout::VERSION::STRING
  end

end
