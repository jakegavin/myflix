class VideoDecorator < Draper::Decorator
  delegate_all

  def show_average_rating
    if !object.reviews.empty?
      object.average_rating ? "Rating: #{object.average_rating}/5.0" : "Rating: N/A"
    else
      return nil
    end
  end
end
