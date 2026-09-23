module ApplicationHelper
  def import_status_label(status)
    {
      "pending" => "pendente",
      "processing" => "processando",
      "completed" => "concluída",
      "failed" => "falhou"
    }.fetch(status.to_s, status.to_s)
  end
end
