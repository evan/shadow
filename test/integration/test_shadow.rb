#!/usr/bin/env ruby

require 'test/unit'

DIR = File.dirname(__FILE__)
require "#{DIR}/../../lib/shadow"

class ShadowText < Test::Unit::TestCase

  def setup
    @s ||= Shadow.new("#{DIR}/../database.yml", "test", "menagerie")
    require "#{DIR}/../schema"
  end
  
  def test_nothing
    assert true
  end
  
  def test_hang
    Process.wait(@s.pid)
  end
    
end
