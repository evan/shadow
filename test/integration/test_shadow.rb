#!/usr/bin/env ruby

require 'rubygems'
require 'test/unit'
require 'curb'

DIR = File.dirname(__FILE__)
require "#{DIR}/../../lib/shadow"

class ShadowText < Test::Unit::TestCase
  URL = "http://0.0.0.0:2001/menagerie/"
  def setup
    $s ||= Shadow.new("#{DIR}/../database.yml", "test", "menagerie", "0.0.0.0", "2001")
    require "#{DIR}/../schema"
    $c ||= Curl::Easy.new
    $c.multipart_form_post = true
  end
  
  def test_get
    $c.url = URL + "cats/1"
    $c.http_get
    assert_equal ActiveRecord::Cat.find(1).to_yaml[-100..-1], $c.body_str[-100..-1]
    assert_equal "text/yaml", $c.content_type
    assert_equal 200, $c.response_code
    $c.url = URL + "cats/25"
    $c.http_get
    assert $c.body_str =~ /RecordNotFound/
    assert_equal 400, $c.response_code
  end
  
  def test_put
  
  end
  
  def test_post
    $c.url = URL + "cats/1"
    $c.http_post(Curl::PostField.content("
    Shadow.d
  end
  
  def test_delete
  
  end
    
  def test_zzzz_im_asleep_zzzzz
    Process.kill(9, $s.pid)
    assert "dead"
  end
    
end
