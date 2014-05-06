class CategoriesController < AuthenticatedUserController
  
  def show
    @category = Category.find(params[:id])
  end
end