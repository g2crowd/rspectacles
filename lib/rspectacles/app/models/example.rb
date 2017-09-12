class Example < ActiveRecord::Base
  belongs_to :run
  serialize :properties, Hash

  def as_json(*_)
    properties
  end
end
