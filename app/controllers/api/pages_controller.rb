module Api
  class PagesController < Api::ApplicationController
    before_action :load_page, only: %i(show)

    def show
      return render json: @page, status: :ok
    end

    private

    def load_page
      begin
        @page = Page.find_by(page_type: params[:id])
      rescue => e
        Rails.logger.error "ERROR: 없는 약관입니다. #{log_info}"
        render json: {error: "없는 약관입니다."}, status: :bad_request
      end
    end
  end
end