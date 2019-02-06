module ApplicationHelper

  def flash_class(level)
    case level.to_s
      when "notice" then "notification is-info"
      when "success" then "notification is-success"
      when "error" then "notification is-warning"
      when "alert" then "notification is-danger"
    end
  end

end
