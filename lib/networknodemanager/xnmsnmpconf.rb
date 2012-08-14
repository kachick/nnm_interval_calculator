# coding: utf-8

require 'time/unit'

module NetworkNodeManager

  module Xnmsnmpconf

    TIMEOUT_INCREASE_RADIX = 2
    TIMEOUT_BASE = Time::Unit.new 100, :msec

    module_function
  
    # 極力リトライ回数が多くなるよう判定する
    # リトライ回数増やした上でも見つからなければ、しぶしぶタイムアウト時間数自体を伸ばす
    def find_neary_settings(range_max_by_alert, interval, min_timeout, min_retry_count)
      timeout  = min_timeout
      
      while timeout < range_max_by_alert.last
        total = 0
        retry_count = min_retry_count
        
        while total < range_max_by_alert.last
          retry_count += 1
          total = (0..retry_count).inject(interval){ |sum, n| sum + timeout * (TIMEOUT_INCREASE_RADIX ** n) }
          return timeout, retry_count if range_max_by_alert.include?(total)
        end
        
        timeout += TIMEOUT_BASE
      end
      
      nil
    end
    
    def each_timeout_with_total(timeout, retry_count)
      total = 0
      0.upto retry_count do |n|
        this  = timeout * (TIMEOUT_INCREASE_RADIX ** n)
        total += this
        yield Time::Unit.new(this, :sec), Time::Unit.new(total, :sec)
      end
    end

  end

end