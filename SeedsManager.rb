#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'Seed'

# 種表現を管理するクラス
class SeedsManager

  def initialize(dbManager)
    @seeds = {}
    @dbManager = dbManager
  end

  # 共通頻出表現と種表現の追加
  def add(seed, common)
    @seeds[seed.name] = seed unless @seeds.key?(seed.name)
    @seeds[seed.name].add_common(common.name)
  end

  # 与えられた種表現のエントロピーの値を取得
  def get_entropy(seed)
    return @seeds[seed.name].entropy
  end

  # 種表現クラスの獲得
  def each_seed
    @seeds.each_value do |seed|
      yield seed
    end
  end

  # 初期化
  def clear_seeds
    @seeds.clear
    Seed.clear
  end

  # 共通頻出表元候補の獲得
#  def getCandidateCommons(seed, sentence)
#    s = @seeds[seed.name]
#    tree = @dbManager.getTree(sentence)
#
#    if tree != nil
#      candidateCommons = s.getCommons(tree)
#      return candidateCommons
#    else
#      return []
#    end
#  end

  # テスト
  def cal(commons, t, tmp = {}, seeds = [], tmp_seeds = [])
    commons.each do |common|
      tmp[common.name] = common.weight
    end

    cal_entropy

    @seeds.each do |key, seed|
      weight = 0

      seed.commons.each do |common, value|
        weight += tmp[common] * (value.to_f / seed.get_common_sum(common)) * seed.entropy
      end

      seed.weight = weight
      tmp_seeds << seed
    end

    seeds = tmp_seeds.sort{|seed1, seed2| seed2.weight <=> seed1.weight}

    return seeds[0..t]
  end

  # エントロピーの計算
  def cal_entropy(seeds = [])
    @seeds.each do |key, seed|
      h = 0.0
      n = seed.get_seed_sum
      n_unique = seed.get_seed_unique

      # 種表現のエントロピーの計算と選別
      seed.commons.each_value do |count|
        probability = count.to_f / n.to_f
        h += probability * ((Math.log10(probability)) / (Math.log10(2)))
      end

      log = (Math.log10(n_unique + 1)) / (Math.log10(2))
      h = -1 * h * (1 / log) + 1

      @seeds[key].entropy = h
    end

    return seeds
  end

private

  # 閾値の設定
  def getThreshold(ne, t_a)
    t = t_a.to_f * ((Math.log10(ne)) / (Math.log10(2)))

    return t
  end

end
