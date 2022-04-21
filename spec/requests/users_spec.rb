require 'rails_helper'

describe "User" do
  describe "POST /users/generate_access_token" do
    it "Generates new token for user" do
      user  = FactoryGirl.create :user
      user.confirm
      login(user)

      expect(user.access_token).to eq nil
      post "/users/generate_access_token"

      expect(response.status).to eq 302
      user.reload
      expect(user.access_token).not_to be_nil
      
    end
  end
  describe "GET /users/:id" do
    it "shows the profile page" do
      user  = FactoryGirl.create :user
      user.confirm
      login(user)

      get "/users/#{user.id}"

      expect(response.status).to eq 200
    end
  end
end

