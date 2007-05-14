#!/usr/bin/env ruby

require 'test/unit'
require '../../lib/shadow'

class ShadowText < Test::Unit::TestCase
  def setup
    @shadow = Shadow.new
  end
  
  def test_nothing
    assert true
  end
    
end
