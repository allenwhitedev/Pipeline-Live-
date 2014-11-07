class Event < ActiveRecord::Base
	belongs_to :user_id
  has_many :reverse_eu_rels, foreign_key: "attended_id",
                                   class_name:  "EuRel",
                                   dependent:   :destroy
  has_many :attenders, through: :reverse_eu_rels, source: :attender
  has_many :oe_rels, class_name: "OeRel", foreign_key: "attender_id", dependent: :destroy
	default_scope -> { order('created_at DESC') } #replace with event_time
	#validates :user_id, presence: true
	validates :title, length: { in: 2..50 }
	validates :comment, length: { maximum: 1000 }


  # Makes event belong to an organization if an organization is provided
  def orga_own(fun_orga)
    oe_rels.create!(attended_id: fun_orga.id, attender_id: self.id)
  end

	# Makes an event belong to an organization(a specific organization, events can belong to multiple organizations)
  def attend!(fun_orga)
    oe_rels.create!(attended_id: fun_orga.id)
  end

  # Makes an event no longer belong to an organization(a specific organization, events can belong to multiple organizations)
  def unattend!(fun_orga)
    oe_rels.find_by(attended_id: fun_orga.id).destroy
  end

  # True if the event belongs to an organization(a specific organization, events can belong to multiple organizations)
  def attending?(fun_orga)
    oe_rels.find_by(attended_id: fun_orga)
  end


end
