require 'kakaocert'

class KakaocertController < ApplicationController
  before_action :authenticate_user!, except: %i(verifyESign)
  before_action :load_booking, only: %i(verifyESign)
  
  # 링크아이디
  LinkID = ENV["KAKAO_CERT_LINK_ID"]
  
  # 비밀키
  SecretKey = ENV["KAKAO_CERT_SERCRET_KEY"]
  
  # kakaoCert 이용기관코드, kakaoCert 파트너 사이트에서 확인
  ClientCode = ENV["KAKAO_CERT_CLIENT_CODE"]
  
  # KakaocertService Instance 초기화
  KCService = KakaocertService.instance(
      KakaocertController::LinkID,
      KakaocertController::SecretKey
  )
  
  # 전자서명을 요청합니다.
  # 결과로 접수 아이디와 카카오톡 트랜잭션 아이디를 반환함.
  def requestESign

    #  전자서명 요청정보 객체
    requestInfo = {

      # App to App 방식 이용 여부
      # true - AppToApp 인증, false - TalkMessage 인증
      "isAppUseYN" => false,

      # 고객센터 전화번호, 카카오톡 인증메시지 중 "고객센터" 항목에 표시
      "CallCenterNum" => ENV["KAKAO_CERT_CALL_CERNTER_NUM"],

      # 인증요청 만료시간(초), 최대값 : 1000  인증요청 만료시간(초) 내에 미인증시, 만료 상태로 처리됨 (권장 : 300)
      "Expires_in" => 300,

      # 수신자 생년월일, 형식 : YYYYMMDD
      "ReceiverBirthDay" => kakaocert_params[:birthday],

      # 수신자 휴대폰번호
      "ReceiverHP" => kakaocert_params[:number],

      # 수신자 성명
      "ReceiverName" => kakaocert_params[:name],

      # 별칭코드, 이용기관이 생성한 별칭코드 (파트너 사이트에서 확인가능)
      # 카카오톡 인증메시지 중 "요청기관" 항목에 표시
      # 별칭코드 미 기재시 이용기관의 이용기관명이 "요청기관" 항목에 표시
      # '모두나눔'이라는 별칭의 별칭코드
      "SubClientID" => ENV["KAKAO_CERT_SUB_CLIENT_ID"],

      # 인증요청 메시지 부가내용, 카카오톡 인증메시지 중 상단에 표시
      "TMSMessage" => '모두나눔 계약서 서명을 위해 인증해주세요',

      # 인증요청 메시지 제목, 카카오톡 인증메시지 중 "요청구분" 항목에 표시
      "TMSTitle" => '모두나눔 - 전자서명',

      # 인증서 발급유형 선택
      # true : 휴대폰 본인인증만을 이용해 인증서 발급
      # false : 본인계좌 점유 인증을 이용해 인증서 발급
      # 카카오톡 인증메시지를 수신한 사용자가 카카오인증 비회원일 경우, 카카오인증 회원등록 절차를 거쳐 은행계좌 실명확인 절차를 밟은 다음 전자서명 가능
      "isAllowSimpleRegistYN" => true,

      # 수신자 실명확인 여부
      # true : 카카오페이가 본인인증을 통해 확보한 사용자 실명과 ReceiverName 값을 비교
      # false : 카카오페이가 본인인증을 통해 확보한 사용자 실명과 RecevierName 값을 비교하지 않음.
      "isVerifyNameYN" => true,

      # 전자서명할 토큰 원문
      # 계약서 내용
      "Token" => kakaocert_params[:token],

      # PayLoad, 이용기관이 생성한 payload(메모) 값
      "PayLoad" => '모두나눔 - 계약서 전자서명',
    }

    begin
      @value = KCService.requestESign(
        KakaocertController::ClientCode,
        requestInfo,
      )
      return render json: @value
    rescue KakaocertException => e
      @code = e.code
      @message = e.message
      Rails.logger.error "인증 에러 코드: #{@code}, 메시지: #{@message} #{log_info}"
      return render json: {code: @code, message: @message}
    end
  end

  # 본인인증 요청시 반환 받은 접수 아이디를 통해 서명 상태를 확인합니다
  def getESignState
    @receiptId = params[:receiptId]

    begin
      @response = KCService.getESignState(
        KakaocertController::ClientCode,
        @receiptId,
      )
      # 전자서명이 완료되었을 때
      if @response["state"] == 1
        return redirect_to kakaocert_verifyESign_path(receiptId: params[:receiptId], booking_id: params[:booking_id]), headers: {Authorization: @token}
      # 전자서명이 미완료되었을 때
      elsif @response["state"] == 0
        Rails.logger.error "전자서명이 완료되지 않았습니다. #{log_info}" 
        return render json: @response
      # 전자서명이 만료되었을 때
      else
        Rails.logger.error "전자서명이 만료됐습니다. #{log_info}" 
        return render json: {error: "전자서명이 만료됐습니다."}, status: :bad_request
      end
    rescue KakaocertException => e
      @code = e.code
      @message = e.message
      Rails.logger.error "인증 에러 코드: #{@code}, 메세지: #{@message} #{log_info}"
      return render json: {code: @code, message: @message}
    end
  end

  # 본인인증 요청시 반환 받은 접수아이디에 해당하는 전자서명값을 검증하며, 전자서명 데이터 전문('signedData')을 반환 받습니다
  # 반환 받은 전자서명 데이터 전문('signedData')와 RequestVerifyAuth 함수 호출시 입력한 Token의 동일 여부를 
  # 확인하여 전자서명 검증을 완료합니다
  def verifyESign
    @receiptId = params[:receiptId]
    
    # AppToApp 앱스킴 성공처리시 반환되는 서명값(iOS-sig, Android-signature)
    # Talk Message 인증시 공백
    if params[:sig].present? # iOS일 경우
      signture = params[:sig]
    elsif params[:signature].present? # Android일 경우
      signture = params[:signature]
    else #App-to-App 방식이 아닌 Talk Message 방식일 경우
      signture = ""
    end

    begin
      @response = KCService.verifyESign(KakaocertController::ClientCode, @receiptId, signture)
      # current_user가 소비자인 경우
      if @booking.user_id == current_user.id
        @booking.update!(consumer_sign_datetime: Time.current)
      # current_user가 제공자인 경우
      else
        @booking.update!(consumer_sign_datetime: Time.current)
      end
      render json: @booking, status: :ok, scope: {params: create_params}
    rescue KakaocertException => e
      @code = e.code
      @message = e.message
      Rails.logger.error "인증 에러 코드: #{@code}, 메세지: #{@message} #{log_info}"
      return render json: {code: @code, message: @message}
    end
  end

  private

  def kakaocert_params
    params.require(:kakaocert).permit(:birthday, :number, :name, :token)
  end

  def load_booking
    begin
      @booking = Booking.find(params[:booking_id])
    rescue => e
      Rails.logger.error "ERROR: 없는 예약입니다. #{log_info}"
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end
end
