![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg

# Home Assistant Add-on: Hass-backup-s3



## What is it for ?

The goal of this addon is not to reimplement home-assistant built in features, so you will not be able to make or delete a snapshot from this addon for example. It main goal is to extend the home-assistant features and to be able to upload your snapshots to any s3 API compatible bucket.

It use the open source tool duplicity to achieve that.



## Installation

Follow these steps to get the add-on installed on your system:

:warning: Important : Make sure you've added my addon repository to your home-assistant addon library : https://github.com/Rbillon59/home-assistant-addons

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "Hass-backup-s3" add-on and click it.
3. Click on the "INSTALL" button.

## How configure it

In the configuration section, set the repository field to your s3 provider access key and secret key.
See the wiki : https://github.com/Rbillon59/hass-backup-s3/wiki/How-to-create-bucket-and-get-keys

### Addon Configuration

Add-on configuration:

```yaml
bucketName: myBucketName
endpointUrl: https://s3.fr-par.scw.cloud
region: fr-par
accessKey: null
secretKey: null
GPGFingerprint: 
GPGPassphrase:
incrementalFor: 7D
removeOlderThan: 14D
restore: false
```

### Oprion: `sourceDir` (required)

Default to /backup. The directory you want to backup

/media and /ssl endpoints are mounted as readonly as well, so you can backup them too

Only one argument is allowed at a time

### Option: `bucketName` (required)

Name of the bucket

### Option: `endpointUrl` (required)

endpoint URL of the s3 provider (contains region)

### Option: `region` (required)

region of the s3 provider

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
    # wait for snapshot done, then upload backup
    - delay: '00:10:00'
    - service: hassio.addon_start
      data:
        addon: "3cfc8f0f_hass_backup_s3"
```

The service *hassio.addon_start* needs the addon slug to work. This is a concatenation of the first 8 char SHA1 hash of the repo url (lowercased) and the addon slug. If I ommit to update this part, you can check by yourself the hash part by taking the first 8 char of the hash here http://www.sha1-online.com/ filling "https://github.com/rbillon59/home-assistant-addons" in the form. It should not happen as the addons repository URL should not change. But in case of ..

You can also launch it manually with the start button in the addon page !

## If you need to restore the backup

Just change the Option: `restore` and set it to true and launch the addon manually. It will download the last available backup of your snapshots.

:warning: Please, think about setting the restore option to false after restoring your backups, or every time you will call it from your automation it will restore the backups in your buckets and not upload it. 

## Support

Got questions?

You can open an issue on Github and i'll try to answer it

[repository]: https://github.com/Rbillon59/hass-backup-s3

## License

As duplicity is distributed under the GPL license, this addon is as well under the same license
