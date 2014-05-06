class QueueItemsController < AuthenticatedUserController

  def index
    @queue_items = current_user.queue_items
  end

  def create
    QueueItem.create(video_id: params[:video_id], user: current_user, position: new_item_position) unless video_in_queue?(params[:video_id])
    redirect_to queue_path
  end

  def modify
    begin
      update_queue_items
      current_user.normalize_queue_items_positions
      flash[:success] = "Your queue was updated."
    rescue => e
      flash[:danger] = "Your queue modifications were invalid."
    end
    redirect_to queue_path
  end

  def destroy
    queue_item = QueueItem.find(params[:id])
    if queue_item.user == current_user
      queue_item.destroy
      current_user.normalize_queue_items_positions
    end
    redirect_to queue_path
  end

  private

  def new_item_position
    current_user.queue_items.size + 1
  end

  def video_in_queue?(video_id)
    !QueueItem.where(user: current_user, video_id: video_id).empty?
  end

  def update_queue_items
    QueueItem.transaction do
      params[:queue_items].each do |item|
        qi = QueueItem.find(item[:id])
        qi.update_attributes!(position: item[:position], rating: item[:rating]) if qi.user == current_user
      end
    end
  end
end