require 'kakaocert'

class KakaocertController < ApplicationController
  before_action :authenticate_user!
  
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
      "CallCenterNum" => '01029921668',

      # 인증요청 만료시간(초), 최대값 : 1000  인증요청 만료시간(초) 내에 미인증시, 만료 상태로 처리됨 (권장 : 300)
      "Expires_in" => 300,

      # 수신자 생년월일, 형식 : YYYYMMDD
      "ReceiverBirthDay" => '19960809',#params[:birth],

      # 수신자 휴대폰번호
      "ReceiverHP" => '01029921668',#params[:phone_number],

      # 수신자 성명
      "ReceiverName" => '마성호',#params[:name],

      # 별칭코드, 이용기관이 생성한 별칭코드 (파트너 사이트에서 확인가능)
      # 카카오톡 인증메시지 중 "요청기관" 항목에 표시
      # 별칭코드 미 기재시 이용기관의 이용기관명이 "요청기관" 항목에 표시
      # '모두나눔'이라는 별칭의 별칭코드
      "SubClientID" => '020110000001',

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
      "Token" => '토큰토큰',#params[:token],

      # PayLoad, 이용기관이 생성한 payload(메모) 값
      "PayLoad" => '모두나눔 전자서명',
    }

    begin
      @value = KCService.requestESign(
        KakaocertController::ClientCode,
        requestInfo,
      )


      render json: @value
    rescue KakaocertException => pe
      @code = pe.code
      @message = pe.message
      render "kakaocert/requestESign"
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
      return render json: @response
    rescue KakaocertException => pe
      @code = pe.code
      @message = pe.message
      render json: {code: @code, message: @message}
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
      render json: @response
    rescue KakaocertException => pe
      @Response = pe
      render json: {error: "전자서명 검증 오류"}
    end
  end

  private

  def kakaocert_params
    params.require(:kakaocert).permit(:birthday, :number, :name)
  end
end