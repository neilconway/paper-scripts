#!/usr/bin/env ruby
# A simple script to check that words are hyphenated consistently in a
# collection of text files (typically TeX source). The idea is that both
# "nondeterministic" and "non-deterministic" are acceptable, but a single
# document should use one variant consistently.
#
# Copyright (c) 2012, Neil Conway; see LICENSE.txt for distribution terms.

require 'set'

if ARGV.empty?
  puts "usage: #{$0} <file> ..."
  exit
end

words = {}
ARGV.each do |f|
  IO.readlines(f).each_with_index do |line, idx|
    # Skip TeX comments
    if line =~ /^(.*)(?<!\\)%/
      line = $1
    end

    line.split(/[\s.,;:{}()\[\]`"\/\\%~]/).each do |w|
      w = w.chomp("''") # remove closing TeX-style quotation marks
      next if w.empty?
      w = w.downcase
      words[w] ||= Set.new
      words[w] << [f, idx + 1]
    end
  end
end

def format_usage(w, words)
  words[w].to_a.sort.map {|l| l.join(":")}.join(", ")
end

words.keys.sort.each do |w|
  next unless w =~ /^(.+)-(.+)$/
  no_hyphen = "#{$1}#{$2}"
  if words.has_key? no_hyphen
    usage_w = format_usage(w, words)
    usage_nh = format_usage(no_hyphen, words)
    puts "\"#{w}\" @ [#{usage_w}], \"#{no_hyphen}\" @ [#{usage_nh}]"
  end
end
