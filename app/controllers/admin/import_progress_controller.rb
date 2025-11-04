module Admin
  class ImportProgressController < Admin::ApplicationController
    def show
      progress = ImportProgress.find(params[:id])
      render json: {
        processed: progress.processed,
        total: progress.total,
        percent: (progress.total.positive? ? (progress.processed.to_f / progress.total * 100).round : 0),
        status: progress.status
      }
    end
  end
end
