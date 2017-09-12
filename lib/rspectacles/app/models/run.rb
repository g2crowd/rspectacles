class Run < ActiveRecord::Base
  has_many :examples, primary_key: :rspec_run, foreign_key: :rspec_run

  def total_count
    @total_count ||= examples.size
  end

  def runtime
    @runtime ||= examples.sum(:duration)
  end
end
