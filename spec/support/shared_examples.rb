shared_examples "requires authenticated user" do
  it "redirects to the root path" do
    clear_current_user
    action
    expect(response).to redirect_to root_path
  end
end

shared_examples "tokenable" do
  it '#generate_token creates a token field for the object' do
    object.generate_token
    expect(object.token).to_not be_nil
  end
  it '#generate_token! creates a token and saves the object' do
    object.generate_token!
    expect(object.reload.token).to_not be_nil
  end
end