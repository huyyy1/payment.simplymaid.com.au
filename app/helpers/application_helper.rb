module ApplicationHelper

  def flash_class(level)
    case level.to_s
      when "notice" then "ui info message"
      when "success" then "ui positive message"
      when "error" then "ui warning message"
      when "alert" then "ui negative message"
    end
  end

end
