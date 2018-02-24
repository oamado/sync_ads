class SyncCampaignService

  def self.call(campaigns)
    # call external API
    ads = get_ads

    # foreach campaigns compare
    sync_result = []

    campaigns.each do |campaign|
      sync_status = create_sync(campaign)

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
        sync_status['current_ad_description'] = ad['description']
        sync_status['sync_status'] = compare_status(campaign['status'], ad['status'])
        sync_status['sync_description'] = compare_description(campaign['ad_description'], ad['description'])
      end
      sync_result << sync_status
    end
    sync_result
  end

  private

  def self.get_ads
    result = Net::HTTP.get(URI.parse('http://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df'))
    result.nil? ? [] : JSON.parse(result)['ads']
  end

  def self.create_sync(campaign)
    {'id': campaign['id'],
     'job_id': campaign['job_id'],
     'status': campaign['status'],
     'external_reference': campaign['external_reference'],
     'ad_description': campaign['ad_description']}
  end

  def self.compare_status(campaign_status, ad_status)
    if (campaign_status == 'active' && ad_status == 'enabled') ||
        (campaign_status == 'paused' && ad_status == 'disabled') ||
        (campaign_status == 'deleted' && ad_status == 'disabled')
      return 'Sync'
    else
      return 'Not Sync'
    end
  end

  def self.compare_description(campaign_description, ad_description)
    if campaign_description == ad_description
      return 'Sync'
    else
      return 'Not Sync'
    end

  end

end