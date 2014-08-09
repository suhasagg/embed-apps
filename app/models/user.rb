class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable #, :confirmable

  has_many :answers 
  has_many :tasks, :through=>:answers
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :anonymous
  attr_accessible :provider, :uid

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.create(username: data["name"],email: data["email"],
                          password: Devise.friendly_token[0,20])
    end
    user
  end

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.new(username:auth.extra.raw_info.name,
                         provider:auth.provider,
                         uid:auth.uid,
                         password:Devise.friendly_token[0,20])
      user.save(:validate => false)
    end
    user
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
  user = User.where(:email => auth.info.email).first
  unless user
    user = User.create(username:auth.extra.raw_info.name,
                         provider:auth.provider,
                         uid:auth.uid,
                         email:auth.info.email,
                         password:Devise.friendly_token[0,20]
                         )
  end
  user
end

end
