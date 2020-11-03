class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: %i(create)

  def create
    @question = current_user.questions.build question_params
    begin
      @question.email = current_user.email
      @question.save
      return render json: @question, status: :ok
    rescue => e
      return render json: {error: e}, status: :bad_request
    end
  end

  private

  def question_params
    params.require(:question).permit(Question::QUESTION_COLUMNS)
  end

end
