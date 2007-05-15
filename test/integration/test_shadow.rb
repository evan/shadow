#!/usr/bin/env ruby

require 'rubygems'
require 'test/unit'
require 'rfuzz/session'

DIR = File.dirname(__FILE__)
require "#{DIR}/../../lib/shadow"

class ShadowText < Test::Unit::TestCase
  APP, HOST, PORT = "menagerie", "0.0.0.0", 2001
  
  def setup
    $client ||= RFuzz::HttpClient.new(HOST, PORT)
    $server ||= Shadow.new("#{DIR}/../database.yml", "test", APP, HOST, PORT, 1)
    require "#{DIR}/../schema"
  end
  
  def test_get
    # successful
    response = $client.get("/#{APP}/cats/1")
    assert_equal ActiveRecord::Cat.find(1).attributes.to_yaml, response.http_body
    assert_equal "text/yaml", response["CONTENT_TYPE"]
    assert_equal "200", response.http_status
    # missing
    response = $client.get("/#{APP}/cats/25")
    assert_match /Couldn't find/, response.http_body
    assert_equal "400", response.http_status
  end
  
  def test_put
    response = $client.put("/#{APP}/cats", :body => {"name" => "Fluffy", "size" => 4}.to_yaml)
    assert YAML.load(response.http_body)["id"]
  end
  
  def test_post
    response = $client.put("/#{APP}/cats/1", :body => {"name" => "Tabby"}.to_yaml)
    assert_equal "Tabby", YAML.load(response.http_body)["name"]
  end
  
  def test_delete
    dog = ActiveRecord::Dog.find(1).attributes
    response = $client.delete("/#{APP}/dogs/1")
    assert_equal dog.to_yaml, response.http_body
    response = $client.delete("/#{APP}/dogs/1")
    assert_match /Couldn't find/, response.http_body
    assert_equal "400", response.http_status
  end
  
  def test_threading
    assert_nothing_raised do
      pids = []
      10.times do 
        pids << fork do
          $client.get("/#{APP}/cats/1") 
        end 
      end
      pids.each do |pid|
        Process.wait(pid)
      end
    end
  end
    
  def test_zzzz_im_asleep_zzzzz
    Process.kill(9, $server.pid)
    assert "dead"
  end
    
end
