module Admin
  class ImportsController < ApplicationController
    before_action :authorize_admin!

    def index
      render inertia: "Admin/Imports/Index", props: {
        imports: -> { ImportSerializer.collection(scope.recent.with_attached_file.limit(25)) }
      }
    end

    def new
      render inertia: "Admin/Imports/New"
    end

    def show
      import = scope.find(params[:id])

      render inertia: "Admin/Imports/Show", props: {
        import: -> { ImportSerializer.new(import).as_json }
      }
    end

    def create
      import = Current.user.imports.new(import_params)

      if import.save
        ProcessImportJob.perform_later(import)
        redirect_to admin_import_path(import), notice: "Import queued."
      else
        redirect_to new_admin_import_path, inertia: { errors: import.errors }
      end
    end

    private

    def scope = Import.all

    def import_params = params.expect(import: [ :file ])

    def authorize_admin!
      raise Authorization::NotAuthorizedError unless Current.user&.admin?
    end
  end
end
