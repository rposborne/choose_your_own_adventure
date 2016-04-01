module Adventure
  class Story < ActiveRecord::Base
    validates :title, presence: true
    has_many :steps
  end
end
