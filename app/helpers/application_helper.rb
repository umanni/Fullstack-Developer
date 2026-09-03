module ApplicationHelper
  def nav_link_classes(path)
    base = "rounded-lg px-3 py-2 text-sm font-medium transition"
    active = "bg-indigo-50 text-indigo-700"
    inactive = "text-slate-600 hover:bg-slate-100 hover:text-slate-950"
    "#{base} #{current_page?(path) ? active : inactive}"
  end

  def field_classes
    "mt-2 block w-full rounded-xl border border-slate-300 bg-white px-3.5 py-2.5 text-slate-950 shadow-sm outline-none transition placeholder:text-slate-400 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-100"
  end

  def status_badge(status)
    colors = {
      "queued" => "bg-slate-100 text-slate-700",
      "processing" => "bg-blue-100 text-blue-800",
      "completed" => "bg-emerald-100 text-emerald-800",
      "completed_with_errors" => "bg-amber-100 text-amber-800",
      "failed" => "bg-rose-100 text-rose-800"
    }
    label = status.to_s.humanize

    tag.span(label, class: "inline-flex rounded-full px-2.5 py-1 text-xs font-semibold #{colors.fetch(status.to_s, colors['queued'])}")
  end

  def import_creator_name(user_import)
    user_import.created_by&.full_name || "Deleted user"
  end
end
