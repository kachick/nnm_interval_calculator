# coding: utf-8

require 'time/unit'
require 'io/nosey'
require_relative 'networknodemanager/xnmsnmpconf'

module NNM_Interval_Calculator

  extend IO::Nosey
  extend NetworkNodeManager
  
  VERSION = '0.0.1'

  class << self

    def run
      loop do
        mode = choose '調べたい内容を選んでください', 
          '見る' => '値から動作シミュレート',
          '探す' => '希望動作を指定して、満たす値を探す'
        
        interval = ask_interval
          
        case mode
        when '見る'
          timeout = ask_timeout
          retry_count = ask_retry_count
        when '探す'
          min_by_alert = ask_min_by_alert
          max_by_alert = ask_max_by_alert min_by_alert
          puts '最小のリトライ値とタイムアウト値を指定して下さい'
          min_timeout = ask_timeout
          min_retry_count = ask_retry_count
          timeout, retry_count = *Xnmsnmpconf.find_neary_settings(
            min_by_alert..max_by_alert, interval, min_timeout, min_retry_count)
          
          if timeout && retry_count
            show_better_settings timeout, retry_count
          else
            puts '要望を満たせるステータスポーリング設定値が見つかりませんでした。'
          end
        end
        
        if timeout && retry_count
          show_nnm_action interval, timeout, retry_count
        end

        break unless agree? '続けて、他の値も調べますか？'
      end
    end
    
    private

    def ask_interval
      ask 'ステータスポーリング間隔は何分ですか？(単位:分)',
        input: /\A\d+\z/,
        parse: ->s{Time::Unit.new s.to_i, :minute},
        return: Time::Unit
    end
    
    def ask_timeout
      ask 'タイムアウトを入力して下さい(単位:ミリ秒)',
        input: /\A\d+\z/,
        parse: ->s{Time::Unit.new s.to_i, :msec},
        return: Time::Unit
    end
    
    def ask_retry_count
      ask 'リトライ回数を入力して下さい(単位:回 / 1～99)',
        input: /\A\d+\z/,
        parse: ->s{s.to_i},
        return: 1..99
    end
    
    def ask_min_by_alert
      ask '通常ステータスポーリング間隔も含め、少なくとも何分以上で検知させますか？(単位:分)',
        input: /\A\d+\z/,
        parse: ->s{Time::Unit.new s.to_i, :minute},
        return: Time::Unit
    end
    
    def ask_max_by_alert(min_by_alert)
      ask '通常ステータスポーリング間隔も含め、最大でも何分以内に検知させますか？(単位:分)',    
        input: /\A\d+\z/,
        parse: ->s{
          minutes = s.to_i
          unless minutes > min_by_alert.min
            raise IO::Nosey::NoseyParker::InvalidInputError, '最小値よりも小さな値を入力しています'
          end
          
          Time::Unit.new minutes, :minute
        },
        return: Time::Unit
    end
    
    def show_better_settings(timeout, retry_count)
      puts '条件を満たすステータスポーリング設定値は、次の通りです。',
        "タイムアウト:\t#{timeout}",
        "リトライ回数:\t#{retry_count}"
    end
    
    def show_nnm_action(interval, timeout, retry_count)
      puts 'この設定値の場合、NNMがどのように動くかを表示します。'
      
      times = 0
      Xnmsnmpconf.each_timeout_with_total timeout, retry_count do |time, total|
        times += 1
        puts "#{times}回目(リトライ#{times - 1})のポーリング\n→タイムアウト: #{time}\t通算待機時間: #{interval + total}"  
      end
    end
  
  end

end

NNM_Interval_Calculator.run
