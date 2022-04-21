class ProgressBar

  def initialize(total)
    @total   = total
    @counter = 1
  end

  def increment(count=1)
    complete = sprintf("%#.2f%%", ((@counter.to_f / @total.to_f) * 100))
    print "\r\e[0K#{@counter}/#{@total} (#{complete})"
    @counter += count
  end

end
