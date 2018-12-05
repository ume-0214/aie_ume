#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'csv'

class SeedStat
  attr_accessor :name
  attr_accessor :commons
  attr_accessor :entropy
  attr_accessor :weight
  attr_accessor :result
  attr_accessor :threshold
  
  def initialize(seed)
    @name = seed
    @commons = {}
    @entropy = 0
  end
  
end

t = ARGV[0]
init = ARGV[1]

path = "/home/ume/workspace/kakaku_result/Camera/examination_result/p-"

(1..10).each do |f|
  lines = []
  seeds = []
  column = []
  weight_list = []
  row = []

  CSV.readlines(path + f.to_s + "/seed_" + init + "_" + t + ".csv").each do |line|
    lines << line
  end

  column = lines[0]
  weight_list = lines[1]

  for i in 2..lines.length - 1
    line = lines[i]

    seed = SeedStat.new(line[0])
    seed.weight = line[1]
    
    for j in 2..line.length - 1
      c = column[j]
      seed.commons[c] = line[j]
    end
    
    seeds << seed
  end

  sort_seeds = seeds.sort{|seed1, seed2| seed2.weight.to_f <=> seed1.weight.to_f}
  
  sort_seeds.each do |seed|
    line = Array.new(column.length, 0)
    line[0..1] = seed.name, seed.weight
    
    seed.commons.each do |common, count|
      index = column.index(common)
      line[index] = count
    end
    
    row << line
  end
  
  CSV.open(path + f.to_s + "/sort_seed_" + init + "_" + t + ".csv", 'w') do |writer|
    writer << column
    writer << weight_list
    
    row.each do |line|
      writer << line
    end
  end
  
end
