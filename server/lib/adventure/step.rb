module Adventure
  class Step < ActiveRecord::Base
    validates :body, presence: true
    belongs_to :story
  end
end
