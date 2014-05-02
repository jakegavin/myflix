class VideosController < AuthenticatedUserController

  def index
    @categories = Category.all
  end

  def show
    @video = Video.find(params[:id])
    @review = Review.new
  end

  def search
    search_term = params[:search_term] || ""
    @videos = Video.search_by_title(search_term)
  end
end