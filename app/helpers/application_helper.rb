module ApplicationHelper
	def current_quiz_user
    session[:quiz_user]
  end

  def flash_class(level)
    case level
      when :notice then "info"
      when :success then "success"
      when :error then "danger"
      when :alert then "danger"
    end
	end
end
