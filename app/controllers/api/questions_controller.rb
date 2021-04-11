module Api
  class QuestionsController < Api::ApplicationController
    before_action :authenticate_user!, only: %i(create)

    def create
      @question = current_user.questions.build question_params
      begin
        @question.email = current_user.email
        @question.save!
        return render json: @question, status: :ok
      rescue => e
        Rails.logger.error "ERROR: #{@question.errors&.first&.last} #{log_info}"
        return render json: {error: @question.errors&.first&.last}, status: :bad_request
      end
    end

    private

    def question_params
      prms = params.require(:question).permit(Question::QUESTION_COLUMNS)
      is_heic?(prms, :images_attributes, :image)
      return prms
    end

  end
end