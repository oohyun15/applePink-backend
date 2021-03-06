class SnsLogin
  attr_reader :auth, :signed_in_resource

  def initialize(auth, signed_in_resource = nil)
    @auth = auth
    @signed_in_resource = signed_in_resource
  end

  def find_user_oauth
    identity = build_identity
    user = @signed_in_resource ? @signed_in_resource : identity.user
    if user.nil?
      begin
        user = User.new get_auth_params
        #user.remote_image_url = @auth.info.image
        user.remote_image_url = @auth.extra&.properties&.profile_image if @auth.extra&.properties&.profile_image&.present?
        user.save!
      rescue => e
        Rails.logger.error "ERROR: #{e}"
      end
    end
    update_identity_user(identity, user)
    user
  end

  private
  def build_identity
    Identity.find_for_oauth(@auth)
  end

  def get_auth_params
    nickname = nil
    loop do
      nickname = @auth.provider+"_"+rand(9999).to_s.rjust(4, "0")
      break unless User.find_by(nickname: nickname).present?
    end
    auth_params = {
      password: Devise.friendly_token[0, 20],
      nickname: nickname,
      account_type: @auth.provider,
      gender: :no_select
    }

    # 이메일은 현재 선택 항목임
    if @auth.info.email.present? && User.find_by(email: @auth.info.email) == nil
      auth_params[:email] = @auth.info.email
    else
      loop do
        uniq_num = SecureRandom.hex(2).downcase
        @generated_email = "#{@auth.info.name}#{uniq_num}@#{@auth.provider}.com"
        break unless User.find_by(email: @generated_email).present?
      end
      auth_params[:email] = @generated_email
    end
    auth_params
  end

  def update_identity_user(identity, user)
    if identity.user != user
      identity.user = user
      identity.save
    end
  end
end