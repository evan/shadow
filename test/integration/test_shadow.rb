#!/usr/bin/env ruby

require 'rubygems'
require 'test/unit'
require 'rfuzz/session'

DIR = File.dirname(__FILE__)
require "#{DIR}/../../lib/shadow"

class ShadowText < Test::Unit::TestCase
  APP, HOST, PORT = "menagerie", "0.0.0.0", 2001
  $client = RFuzz::HttpClient.new(HOST, PORT)
  $server = Shadow.new("#{DIR}/../database.yml", "test", APP, HOST, PORT, 1)
  require "#{DIR}/../schema"
    
  def test_get
    # successful
    response = $client.get("/#{APP}/cats/1")
    assert_match /name: Blue/, response.http_body
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
    response = $client.put("/#{APP}/cats/2", :body => {"name" => "Tabby"}.to_yaml)
    assert_equal "Tabby", YAML.load(response.http_body)["name"]
    response = $client.get("/#{APP}/cats/2")
    assert_equal "Tabby", YAML.load(response.http_body)["name"]
  end
  
  def test_delete
    response = $client.delete("/#{APP}/dogs/1")
    assert_match /name: Rover/, response.http_body
    response = $client.delete("/#{APP}/dogs/1")
    assert_match /Couldn't find/, response.http_body
    assert_equal "400", response.http_status
  end
  
  def test_concurrent_reads
    correct_result = $client.get("/#{APP}/cats/1").http_body
    assert_nothing_raised do
      pids = []
      100.times do
        pids << fork do # can't use Thread because RFuzz isn't threadsafe?
          result = $client.get("/#{APP}/cats/1").http_body
          puts "Response error: #{result}" unless correct_result == result 
        end 
      end
      pids.each {|pid| Process.wait(pid)}
    end
  end

  def test_concurrent_writes
    assert_nothing_raised do
      pids = []
      100.times do
        pids << fork do
          result = $client.put("/#{APP}/dogs", 
                                        :body => {"name" => Process.pid.to_s}.to_yaml)
          id = YAML.load(result.http_body)["id"]
          sleep(2)
          result = $client.get("/#{APP}/dogs/#{id}").http_body
          puts "Response error: #{result.inspect}" unless result =~ /#{Process.pid}/
        end 
      end
      pids.each {|pid| Process.wait(pid)}
    end
  end
    
  def test_zzzz_im_asleep_zzzzz
    Process.kill(9, $server.pid)
    assert "dead"
  end
    
end
