require 'hiatus/extras/file_count_threshold'

RSpec.describe Hiatus::FileCountThreshold do

  after { File.delete('any_file_path') }

  subject { described_class.new 'any_file_path' }

  it "stores the count in a file" do
    5.times { subject.increment }

    expect(subject).to be_reached

    subject.reset

    expect(subject).not_to be_reached
  end
end