module ApplicationHelper
  def options_for_review_rating(current_rating=nil)
    options_for_select([1,2,3,4,5].map { |num| [pluralize(num, 'Star'), num] }.unshift(["Select rating", nil]), selected: current_rating)
  end

  def video_in_current_users_queue?(video)
    if logged_in?
      current_user.queue_items.map(&:video).include?(video)
    else
      false
    end
  end
end