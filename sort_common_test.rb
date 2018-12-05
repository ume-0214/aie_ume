#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'csv'

class CommonStat
  attr_accessor :name
  attr_accessor :seeds
  attr_accessor :entropy
  attr_accessor :weight
  attr_accessor :result
  attr_accessor :threshold
  
  def initialize(common)
    @name = common
    @seeds = {}
    @entropy = 0
  end
  
end

t = ARGV[0]
init = ARGV[1]

path = "/home/ume/workspace/kakaku_result/Camera/examination_result/p-"

(1..10).each do |f|
  lines = []
  commons = []
  column = []
  weight_list = []
  row = []

  CSV.readlines(path + f.to_s + "/common_" + init + "_" + t + ".csv").each do |line|
    lines << line
  end
  
  column = lines[0]
  weight_list = lines[1]
  
  for i in 2..lines.length - 1
    line = lines[i]

    common = CommonStat.new(line[0])
    common.weight = line[1]
    
    for j in 2..line.length - 1
      s = column[j]
      common.seeds[s] = line[j]
    end
    
    commons << common
  end
  
  sort_commons = commons.sort{|common1, common2| common2.weight.to_f <=> common1.weight.to_f}
  
  sort_commons.each do |common|
    line = Array.new(column.length, 0)
    line[0..1] = common.name, common.weight
    
    common.seeds.each do |seed, count|
      index = column.index(seed)
      line[index] = count
    end

    row << line
  end

  CSV.open(path + f.to_s + "/sort_common_" + init + "_" + t + ".csv", 'w') do |writer|
    writer << column
    writer << weight_list

    row.each do |line|
      writer << line
    end
  end

end
