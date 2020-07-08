module Hiatus
  # an example of threshold that could be stored somewhere
  # file's really simple to implement.
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
      failure_count, threshold = *deserialize
      failure_count >= threshold
    end

    def reset
      super
      serialize
    end

    private

    def deserialize
      JSON.parse IO.binread(@file_path)
    end

    def serialize
      IO.binwrite @file_path, JSON.dump([@failure_count, @threshold])
    end
  end
end