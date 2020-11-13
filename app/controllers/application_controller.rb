class ApplicationController < ActionController::Base
  include ActionView::Helpers::NumberHelper
  skip_before_action :verify_authenticity_token
  attr_reader :current_user

  helper_method :money, :short_time, :long_time, :short_date, :push_notification
  
  public
  
  def money num
    number_to_currency num.to_i rescue ""
  end
  
  def short_time time
    time.methods.include?(:strftime) ? time.strftime("%m/%d %H:%M") : nil
  end
  
  def long_time time
    time.methods.include?(:strftime) ? time.strftime("%Y.%m.%d %H:%M") : nil
  end
  
  def short_date date
    date.methods.include?(:strftime) ? date.strftime("%Y년 %m월 %d일") : nil
  end

  def push_notification body, title, registration_ids
    begin
      # check devices
      if registration_ids.blank?
        Rails.logger.error "ERROR: No available devices."
        return nil
      end

      # initialize FCM
      app = FCM.new(ENV['FCM_SERVER_KEY'])

      # options
      options = {
        "notification": {
          "title": "#{title}",
          "body": "#{body}"
        }
      }

      # send notification
      app.send(registration_ids, options)

    rescue => e
      Rails.logger.error "ERROR: #{e}"
      return nil
    end
  end
  
  protected
  
  def authenticate_user!
    ## 토큰 안에 user id 정보가 있는지 확인 / 없을 시 error response 반환
    unless user_id_in_token?
      # redirect_to users_sign_in_path
      Rails.logger.error "ERROR: Unauthorized"
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    ## Token 안에 있는 user_id 값을 받아와서 User 모델의 유저 정보 탐색
    @current_user = User.find(auth_token[:user_id])
    Rails.logger.info "JWT: #{http_token}"
    Rails.logger.info "Expired Time: #{Time.at(auth_token[:exp])}"
    Rails.logger.info "User ID: #{@current_user.id}, nickname: #{@current_user.nickname}"
    rescue JWT::VerificationError, JWT::DecodeError
      # redirect_to users_sign_in_path
      Rails.logger.error "ERROR: Unauthorized"
      return render json: { error: "unauthorized" }, status: :unauthorized
  end

  # 리다이렉트 기본 값
  def redirect_to_default
    redirect_to root_path
  end

  def payload(user)
    ## 해당 코드 예제에서 토큰 만료기간은 '30일' 로 설정
    @token = JWT.encode({ user_id: user.id, exp: 7.days.from_now.to_i }, ENV["SECRET_KEY_BASE"])
    # @tree = { jwt: @token, userInfo: { id: user.id, email: user.email } }

    return @token
  end

  def heic2png(image_path)
    api_instance = CloudmersiveConvertApiClient::ConvertImageApi.new
    
    begin
      input_file = File.new(image_path)  
    rescue => e
      Rails.logger.error "ERROR: #{e}"
      return render json: {error: e}, status: :bad_request
    end

    begin
      #Image format conversion
      result = api_instance.convert_image_image_format_convert("HEIC", "PNG", input_file)
      image = MiniMagick::Image.read(result)
      image.resize "25%"
      image.format "png"
      # image.write "output.png"
      return image
    rescue CloudmersiveConvertApiClient::ApiError => e
      Rails.logger.error "ERROR: Exception when calling ConvertImageApi->convert_image_image_format_convert: #{e}"
    end
  end

  def is_heic?(column)
    model = controller_name.singularize.to_sym
    params.dig(model, column)&.content_type == "image/heic"
  end

  private

  ## 헤더에 있는 정보 중, Authorization 내용(토큰) 추출
  def http_token
    http_token ||= if request.headers["Authorization"].present?
        request.headers["Authorization"].split(" ").last
      end
      # Rails.logger.info "http_token: #{http_token}"
      return http_token
  end

  ## 토큰 해석 : 토큰 해석은 lib/json_web_token.rb 내의 decode 메소드에서 진행됩니다.
  def auth_token
    auth_token ||= JsonWebToken.decode(http_token)
    # Rails.logger.info "auth_token: #{auth_token}"
    return auth_token
  end

  ## 토큰 해석 후, Decode 내용 중 User id 정보 확인
  def user_id_in_token?
    http_token && auth_token && auth_token[:user_id].to_i
  end

  def create_params
    begin
      @params = (request.post? || request.put?) ? JSON.parse(request.body.read) : request.params
      ActionController::Parameters.new(@params)
    rescue
      {}
    end
  end
end
