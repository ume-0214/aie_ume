#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'Common'

# 複数の共通頻出表現を管理するクラス
class CommonsManager

  def initialize(dbManager)
    @commons = {}
    @dbManager = dbManager
  end

  # 共通頻出表現と種表現の追加
  def add(common, seed)
    @commons[common.name] = common unless @commons.key?(common.name)
    @commons[common.name].add_seed(seed.name)
  end

  # 与えられた共通頻出表現のエントロピーの値を取得
  def get_entropy(common)
    return @commons[common].entropy
  end

  # 共通頻出表現クラスの取得
  def each_common
    @commons.each_value do |common|
      yield common
    end
  end

  # 共通頻出表現の情報を初期化
  def clear_commons
    @commons.clear
    Common.clear
  end

  # 種表現候補の取得
#  def getCandidateSeeds(common, sentence)
#    c = @commons[common.name]
#    tree = @dbManager.getTree(sentence)
#
#    if tree != nil
#      candidateSeeds = c.getSeeds(tree)
#      return candidateSeeds
#    else
#      return []
#    end
#  end

  # テスト
  def cal(seeds, t, tmp = {}, commons = [], tmp_commons = [])
    seeds.each do |seed|
      tmp[seed.name] = seed.weight
    end

    cal_entropy

    @commons.each do |key, common|
      weight = 0

      common.seeds.each do |seed, value|
        weight += tmp[seed] * (value.to_f / common.get_seed_sum(seed)) * common.entropy
      end

      common.weight = weight
      tmp_commons << common
    end

    commons = tmp_commons.sort{|common1, common2| common2.weight <=> common1.weight}

    return commons[0..t]
  end

  # エントロピーの計算
  def cal_entropy(total = 0, commons = [])
    @commons.each do |key, common|
      h = 0.0
      n = common.get_common_sum
      n_unique = common.get_common_unique

      # 共通頻出表現のエントロピーの計算
      common.seeds.each_value do |count|
        probability = count.to_f / n.to_f
        h += probability * ((Math.log10(probability)) / (Math.log10(2)))
      end

      log = (Math.log10(n_unique + 1)) / (Math.log10(2))
      h = -1 * h * (1 / log) + 1

      @commons[key].entropy = h
    end

    return commons
  end

private

  # 閾値の設定
  def getThreshold(ns, t_a)
    t = t_a.to_f * ((Math.log10(ns)) / (Math.log10(2)))

    return t
  end

end
