require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do

  describe 'POST #sync_ads' do
    it 'returns http success' do
      post :sync_ads, params: {campaigns: ['foo'], format: :json }
      expect(response).to have_http_status(:success)
    end

    it 'call the ads API' do
      expect(Net::HTTP).to receive(:get).once
      post :sync_ads, params: {campaigns: ['foo'], format: :json }
    end

    it "when ad doesn't exist it returns Ad doesn't exist" do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'active',
                  'external_reference': 1,
                  'ad_description': 'foo'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_status']).to eq("Ad doesn't exist")
    end

    it "when the campaign doesn't have a external_reference it returns Campaign doesn't have external_id" do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'active',
                  'external_reference': nil,
                  'ad_description': 'foo'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_status']).to eq("Campaign doesn't have external_id")

    end

    it 'when the campaign is active and the ad is enabled returns Sync' do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'active',
                  'external_reference': '1',
                  'ad_description': 'foo'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[{\"reference\":\"1\",\"status\":\"enabled\"}]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_status']).to eq('Sync')
    end

    it 'when the campaign is active and the ad is disabled returns Not Sync' do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'active',
                  'external_reference': '1',
                  'ad_description': 'foo'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[{\"reference\":\"1\",\"status\":\"disabled\"}]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_status']).to eq('Not Sync')
    end

    it 'when the campaign is paused and the ad is enabled returns Not Sync' do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'paused',
                  'external_reference': '1',
                  'ad_description': 'foo'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[{\"reference\":\"1\",\"status\":\"enabled\"}]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_status']).to eq('Not Sync')
    end


    it 'when the campaign is paused and the ad is disabled returns Sync' do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'paused',
                  'external_reference': '1',
                  'ad_description': 'foo'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[{\"reference\":\"1\",\"status\":\"disabled\"}]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_status']).to eq('Sync')
    end

    it 'when the campaign is deleted and the ad is enabled returns Not Sync' do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'deleted',
                  'external_reference': '1',
                  'ad_description': 'foo'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[{\"reference\":\"1\",\"status\":\"enabled\"}]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_status']).to eq('Not Sync')
    end

    it 'when the campaign is deleted and the ad is disabled returns Sync' do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'deleted',
                  'external_reference': '1',
                  'ad_description': 'foo'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[{\"reference\":\"1\",\"status\":\"disabled\"}]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_status']).to eq('Sync')
    end

    it 'when the description is synchronized returns sync' do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'deleted',
                  'external_reference': '1',
                  'ad_description': 'foo'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[{\"reference\":\"1\",\"status\":\"disabled\",
                                                      \"description\":\"foo\"}]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_description']).to eq('Sync')
    end


    it 'when the description is desynchronized returns not sync' do
      campaign = {'id': 1,
                  'job_id': 1,
                  'status': 'deleted',
                  'external_reference': '1',
                  'ad_description': 'foo2'}
      expect(Net::HTTP).to receive(:get).and_return("{\"ads\":[{\"reference\":\"1\",\"status\":\"disabled\",
                                                      \"description\":\"foo\"}]}")

      post :sync_ads, params: { campaigns: [campaign], format: :json }

      resp = JSON.parse(response.body)
      expect( resp['campaigns'][0]['sync_description']).to eq('Not Sync')
    end


  end

end
