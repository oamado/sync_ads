# README

This is a rails app build to sync campaigns and ads status.


* How to run
```bash
rails s
```

* How to run the test suite

```bash
bundle exec rspec
```

* Making a request
```bash
curl -X POST \
  http://localhost:3000/campaigns/sync_ads \
  -H 'content-type: application/json' \
  -d '{"campaigns":[{"id": 1,
                  "job_id": 1,
                  "status": "deleted",
                  "external_reference": "1",
                  "ad_description": "foo"}]}'
```


This endpoint receives the campaigns to check and returns these campaigns with four fields more
 - sync_status: Value that compares campaign and ad status
 - sync_description: Value that compares campaign and ad description
 - ad_status: The actual ad status
 - current_ad_description: the actual ad description

 The response of the previous request is:

 ```json
{
    "campaigns": [
        {
            "id": 1,
            "job_id": 1,
            "status": "deleted",
            "external_reference": "1",
            "ad_description": "foo",
            "ad_status": "enabled",
            "current_ad_description": "Description for campaign 11",
            "sync_status": "Not Sync",
            "sync_description": "Not Sync"
        }
    ]
}
 ```
