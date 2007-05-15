#!/usr/bin/env ruby

require 'rubygems'
require 'test/unit'
require 'curb'

DIR = File.dirname(__FILE__)
require "#{DIR}/../../lib/shadow"

class ShadowText < Test::Unit::TestCase

  def setup
    $s ||= Shadow.new("#{DIR}/../database.yml", "test", "menagerie")
    require "#{DIR}/../schema"
  end
  
  def test_get
    
  end
  
  def test_put
  
  end
  
  def test_post
  
  end
  
  def test_delete
  
  end
  
  def test_error
  
  end
  
  def test_zzzz_im_asleep_zzzzz
    Process.kill(9, $s.pid)
    assert "dead"
  end
    
end
