require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do

  describe "GET #sync_ads" do
    it "returns http success" do
      get :sync_ads
      expect(response).to have_http_status(:success)
    end
  end

end
