module Hiatus
  class ThreadPool


    def initialize(threads)
      @threads = threads
      @pool = Queue.new
    end

    def acquire(&block)
      thread = @pool.pop
       
    end
  end
end