module Gitlock
  
  def gitlock(path, &block)
    lockfile = path+"/git.lock"
    counter = 0
    while File.exists? lockfile
      if counter > 5
        raise "Couldn't get git lock after #{counter} attempts"
      end
      sleep 5
      counter += 1
    end
    begin
      FileUtils.touch lockfile
      block.call
    ensure
      File.delete lockfile
    end
  end

end
