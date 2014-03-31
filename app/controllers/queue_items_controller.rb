class QueueItemsController < ApplicationController
  before_action :require_user

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
      current_user.normalize_queue_items
    rescue => e
      flash[:danger] = "Your position values were invalid."
    end
    redirect_to queue_path
  end

  def destroy
    queue_item = QueueItem.find(params[:id])
    if queue_item.user == current_user
      queue_item.destroy
      current_user.normalize_queue_items
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
        if qi.user == current_user
          qi.position = item[:position]
          qi.save!
        end
      end
    end
  end
end