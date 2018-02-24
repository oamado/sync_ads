require 'net/http'

class CampaignsController < ApplicationController
  def sync_ads
    campaigns = params[:campaigns]


    head :bad_request and return unless campaigns

    # call external API
    result = Net::HTTP.get(URI.parse('http://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df'))
    ads = result.nil? ? [] : JSON.parse(result)['ads']

    # foreach campaigns compare
    sync_result = []

    campaigns.each do |campaign|

      sync_status = {'id': campaign['id'],
                     'job_id': campaign['job_id'],
                     'status': campaign['status'],
                     'external_reference': campaign['external_reference'],
                     'ad_description': campaign['ad_description']}



      if campaign['external_reference'].nil? || campaign['external_reference'].empty?
        sync_status['sync_status'] = "Campaign doesn't have external_id"
        sync_result << sync_status
        next
      end

      ad = ads.first { |ad| ad['reference'] == campaign['external_reference'] }
      if ad.nil? || ad.empty?
        sync_status['sync_status'] = "Ad doesn't exist"
      else
        sync_status['ad_status'] = ad['status']
        sync_status['ad_description'] = ad['description']

        if (campaign['status'] == 'active' && ad['status'] == 'enabled') ||
              (campaign['status'] == 'paused' && ad['status'] == 'disabled') ||
              (campaign['status'] == 'deleted' && ad['status'] == 'disabled')
          sync_status['sync_status'] = 'Sync'
        else
          sync_status['sync_status'] = 'Not Sync'
        end

        if campaign['ad_description'] == ad['description']
          sync_status['sync_description'] = 'Sync'
        else
          sync_status['sync_description'] = 'Not Sync'
        end

      end

      sync_result << sync_status
    end


    # return a solution
    render json: {'campaigns': sync_result}
  end

end
