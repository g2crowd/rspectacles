class Example < ActiveRecord::Base
  belongs_to :run, primary_key: :rspec_run, foreign_key: :rspec_run
  serialize :properties, Hash

  def as_json(*_)
    properties
  end
end
