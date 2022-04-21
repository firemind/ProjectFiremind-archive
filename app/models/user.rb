class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable, :omniauth_providers => [:twitter, :google_oauth2, :facebook, :github]
  has_many :decks, foreign_key: "author_id"
  has_many :ratings, through: :decks
  has_many :card_script_submissions
  has_many :card_requests
  has_many :deck_challenges
  acts_as_voter


  acts_as_followable
  acts_as_follower

  has_many :duels
  has_many :meta
  has_many :card_script_claims
  has_many :ai_mistakes
  has_many :mulligan_decisions
  has_many :duel_queues
  validates_presence_of :name
  def to_s
    name
  end

  def self.dummy_user
    User.find 71
  end

  def max_queued_games
    55
  end

  def queued_games_count
    duels.waiting.sum('games_to_play')
  end

  def self.from_omniauth(auth)
    user = where(email: auth.info.email).first if auth.info.email
    user ||= where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.nickname || auth.info.name
      user.email = auth.info.email if auth.info.email
    end
    user.confirmed_at ||= Time.now
    user.save!
    user
  end

  #def self.new_with_session(params, session)
    #if session["devise.user_attributes"]
      #new(session["devise.user_attributes"], without_protection: true) do |user|
        #user.attributes = params
        #user.valid?
      #end
    #else
      #super
    #end
  #end

  def password_required?
    super && provider.blank?
  end

  def email_required?
    super && uid.blank?
  end

  def generate_access_token!
    self.access_token = SecureRandom.hex
    self.save!
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def self.get_sys_user
    self.where(sysuser: true, email: 'redacted').first
  end

  def self.sysuser
    self.get_sys_user
  end


  def gravatar_url
    e = self.email.downcase
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(e)}"
  end

  def airm_authorized?
    !!self.airm_admin
  end

  def token_validation_response
    {
      email: self.email,
      name: self.name,
      uid: self.email,
      sender_id: "155500894304"
    }.as_json
  end

  protected

  # only validate unique email among users that registered by email
  def unique_email_user
    #if provider == 'email' and self.class.where(provider: 'email', email: email).count > 0
    if self.class.where(email: email).count > 0
      errors.add(:email, I18n.t("errors.messages.taken"))
    end
  end

end
