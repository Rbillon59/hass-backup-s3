# Home Assistant Add-on: Hass-backup-s3

## What is it for ?

The goal of this addon is not to reimplement home-assistant built in features, so you will not be able to make or delete a snapshot from this addon for example. It main goal is to extend the home-assistant features and to be able to upload your snapshots to any s3 API compatible bucket.

It use the open source tool duplicity to achieve that.



## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "Hass-backup-s3" add-on and click it.
3. Click on the "INSTALL" button.

## How configure it

In the configuration section, set the repository field to your s3 provider access key and secret key.


### Addon Configuration

Add-on configuration:

```yaml
bucketUrl: 's3://my.s3.provider/myBucketName'
accessKey: null
secretKey: null
GPGFingerprint: 
GPGPassphrase:
incrementalFor: 7D
removeOlderThan: 14D
```

### Option: `bucketUrl` (required)

S3 compatible URL, could be s3:// or b2://[accessKey]:[secretKey]@[B2 bucket name].

### Option: `accessKey` (required if not using Backblaze b2)

Access key, see documentation how to get it from a s3 provider

### Option: `secretKey` (required if not using Backblaze b2)

Secret key, see documentation how to get it from a s3 provider

### Option: `GPGFingerprint` (optionnal)

The GPG public key id of your GPG key

### Option: `GPGPassphrase` (optionnal)

GPGPassphrase is the password you set for your GPG key

### Option: `incrementalFor` (optionnal)

If not set, the addon will make a full backup of all your snapshots in the bucket each time it will be called.
You can set here the number of days of incremental backup before making a full backup again. The default value of 7 means, if you schedule a homeassistant snapshot every day and then trigger the addon every day after the backup, the first addon start with a full backup with the snapshot you just created. Then the day after, a new snapshot will be created and the addon will upload just the newly created snapshot. After 6 day, you will have 6 snapshots on your local and 6 in your s3 bucket. But on the 7th day, a full backup will be triggered and it will upload again the 6 local backup + the seventh local backup in once.

As say, a full backup will upload ALL the home-assistant /backup folder
An incremental will upload the diff between the local /backup and the files in the bucket`

### Option: `restore` (required)

Default to false. Is set to true, will download the s3 content inside the backup folder to restore the snapshot.

## How to use it ?

Call this addon from your backup automations to trigger it :

```yaml
- alias: Snapshot Once A Week
  trigger:
    - platform: time
      at: '10:00:00'
  condition:
    - condition: time
      weekday:
        - wed
  action:
    - service: hassio.snapshot_full
      data_template:
        name: >
          weekly_backup_{{ now().strftime('%Y-%m-%d') }}
    - service: hassio.addon_start
      data:
        addon: "home-assistant-s3"
```

Or launch it manually with the start button in the addon page !

## If you need to restore the backup



## Support

Got questions?

You can open an issue on Github and i'll try to answer it

[repository]: https://github.com/Rbillon59/hass-backup-s3

## License

As duplicity is distributed under the GPL license, this addon is as well under the same license