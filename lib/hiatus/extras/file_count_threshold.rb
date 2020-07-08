module Hiatus
  class FileCountThreshold < CountThreshold
    def initialize(file_path, threshold = 5)
      @file_path = file_path
      super threshold
    end

    def increment
      super
      serialize
    end

    def reached?
      failure_count, threshold = *JSON.parse(IO.binread(@file_path))
      failure_count >= threshold
    end

    def reset
      super
      serialize
    end

    private

    def serialize
      IO.binwrite @file_path, JSON.dump([@failure_count, @threshold])
    end

    def touch; end;
  end
end