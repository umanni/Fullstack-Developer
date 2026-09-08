# frozen_string_literal: true

module Admin
  # Thin controller (fase 5): create only builds the UserImport + enqueues
  # the job; parser/validation/aggregation all live in Parser/Model/Processor.
  # Reads go through ListingQuery + UserImportPresenter (DIP).
  class UserImportsController < BaseController
    def index
      listing = UserImports::ListingQuery.call(page: params[:page])

      render inertia: "Admin/UserImports/Index", props: {
        imports: list_items(listing.imports),
        pagination: listing.pagination,
        urls: admin_urls.merge(new_import_url: new_admin_user_import_path)
      }
    end

    def new
      render inertia: "Admin/UserImports/New", props: {
        imports: list_items(recent_imports),
        urls: admin_urls.merge(submit_url: admin_user_imports_path)
      }
    end

    def create
      user_import = UserImport.new(user: Current.user, status: :pending)
      user_import.file = params[:file]

      if user_import.save
        UserImports::Job.perform_later(user_import)
        redirect_to admin_user_import_path(user_import),
                    notice: "#{user_import.file.filename} queued for processing."
      else
        render inertia: "Admin/UserImports/New", props: {
          imports: list_items(recent_imports),
          errors: user_import.errors.to_hash,
          urls: admin_urls.merge(submit_url: admin_user_imports_path)
        }
      end
    end

    def show
      user_import = UserImport.find(params[:id])

      render inertia: "Admin/UserImports/Show", props: {
        import: UserImportPresenter.new(user_import).to_inertia,
        urls: admin_urls.merge(imports_url: admin_user_imports_path)
      }
    end

    private

    def admin_urls
      {
        dashboard_url: admin_root_path,
        users_url: admin_users_path,
        imports_url: admin_user_imports_path
      }
    end

    def recent_imports
      UserImport.order(id: :desc).limit(5)
    end

    def list_items(imports)
      imports.map do |record|
        UserImportPresenter.new(record).to_inertia.merge(
          show_url: admin_user_import_path(record)
        )
      end
    end
  end
end
