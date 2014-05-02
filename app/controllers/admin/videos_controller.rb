class Admin::VideosController < AdminController
  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    @video.small_cover_url = "" if @video.small_cover_url.nil?
    @video.large_cover_url = "" if @video.large_cover_url.nil?
    if @video.save
      flash[:success] = "#{@video.title} was added to the system."
      redirect_to home_path
    else
      render :new
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, category_ids: [])
  end
end