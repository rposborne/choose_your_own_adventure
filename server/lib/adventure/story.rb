module Adventure
  class Story < ActiveRecord::Base
    validates :title, presence: true
    has_many :steps
    belongs_to :first_step, class_name: "Step"

    def step=(args)
      return unless args.respond_to?(:keys)
      steps << build_first_step(args)
    end
  end
end
