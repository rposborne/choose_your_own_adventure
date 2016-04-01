module Adventure
  class Story < ActiveRecord::Base
    has_many :steps
  end
end
