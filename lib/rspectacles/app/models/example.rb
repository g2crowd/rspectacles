class Example < ActiveRecord::Base
  serialize :properties, Hash

  def as_json(*_)
    properties
  end
end
