require 'net/http'

class CampaignsController < ApplicationController
  def sync_ads
    campaigns = params[:campaigns]
    head :bad_request and return unless campaigns

    sync_result = SyncCampaignService.call(campaigns)

    render json: {'campaigns': sync_result}
  end

end
