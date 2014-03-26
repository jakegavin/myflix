class QueueItemsController < ApplicationController
  before_action :require_user

  def index
    @queue_items = current_user.queue_items
  end

  def create
    QueueItem.create(video_id: params[:video_id], user: current_user, position: new_item_position) unless video_in_queue?(params[:video_id])
    redirect_to queue_path
  end

  def destroy
    queue_item = QueueItem.find(params[:id])
    if queue_item.user == current_user
      decrease_following_item_positions(queue_item)
      queue_item.destroy
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

  def decrease_following_item_positions(queue_item)
    index = current_user.queue_items.find_index(queue_item)
    unless current_user.queue_items[-1] == queue_item
      current_user.queue_items[index+1..-1].each do |item|
        item.position -= 1
        item.save
      end  
    end
    
  end

end