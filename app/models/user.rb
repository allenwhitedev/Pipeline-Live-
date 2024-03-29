class User < ActiveRecord::Base
	has_many :events, dependent: :destroy
	has_many :eu_rels, class_name: "EuRel", foreign_key: "attender_id", dependent: :destroy
	has_many :ou_rels, class_name: "OuRel", foreign_key: "joiner_id", dependent: :destroy
	has_many :attended_events, through: :eu_rels, source: :attended 

	before_save { self.email = email.downcase }
	before_create :create_remember_token
	attr_accessor :reset_token
	
	validates :name, length: { in: 2..50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, uniqueness: true, length: { in: 2..50 }, format: { with: VALID_EMAIL_REGEX }
	validates :password, length: { minimum: 6 }
	has_secure_password

	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.digest(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def feed
		#Will add so that only feed of organization(s) user belongs to is shown
		Event.where("user_id = ?", id)
	end

	 # Attends an event
  def attend!(fun_event)
    eu_rels.create!(attended_id: fun_event.id)
    @pluspoints = self.total_points+=fun_event.points
    self.update_attribute(:total_points, @pluspoints)
  end

  # Unattends an event
  def unattend!(fun_event)
    eu_rels.find_by(attended_id: fun_event.id).destroy
  end

  # True if user is attending the event
  def attending?(fun_event)
    eu_rels.find_by(attended_id: fun_event)
  end

  # Joins an organization
  def join!(fun_orga)
    ou_rels.create!(joined_id: fun_orga.id)
  end

  # Leaves an organization
  def unjoin!(fun_orga)
    ou_rels.find_by(joined_id: fun_orga.id).destroy
  end

  # True if user is a member of the organization
  def joined?(fun_orga)
    ou_rels.find_by(joined_id: fun_orga)
  end


  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def create_reset_digest
  	self.reset_token = User.digest(User.new_remember_token)
  	update_attribute(:reset_digest, reset_token)#self.reset_token?
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

private
	
	def create_remember_token
		self.remember_token = User.digest(User.new_remember_token)
	end


end

