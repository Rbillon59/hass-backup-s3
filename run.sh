#!/usr/bin/with-contenv bashio

CONFIG_PATH=/data/options.json

#####################
## USER PARAMETERS ##
#####################

# REQUIRED
BUCKET_URL="$(bashio::config 'bucketUrl')"
export AWS_ACCESS_KEY_ID="$(bashio::config 'accessKey')"
export AWS_SECRET_ACCESS_KEY="$(bashio::config 'secretKey')"
export GPG_FINGERPRINT="$(bashio::config 'GPGFingerprint')"
export PASSPHRASE="$(bashio::config 'GPGPassphrase')"
RESTORE="$(bashio::config 'restore')"

# OPTIONNAL
DAY_BEFORE_FULL_BACKUP="$(bashio::config 'incrementalFor')"
DAY_BEFORE_REMOVING_OLD_BACKUP="$(bashio::config 'removeOlderThan')"

###########
## MAIN  ##
###########

############################
## SET DUPLICITY OPTIONS  ##
############################

if [[ -z "${GPG_FINGERPRINT}" ]] || [[ -z "${PASSPHRASE}" ]]; then
    NO_ENCRYPTION='--no-encryption'
else
    echo "Encrypting snapshots before upload $(ls -l /backup)"
fi

if [[ -n ${DAY_BEFORE_FULL_BACKUP} ]]; then
	DUPLICITY_FULL_BACKUP_AFTER="--full-if-older-than ${DAY_BEFORE_FULL_BACKUP}"
fi

############################
## SET DUPLICITY COMMAND  ##
############################

if [[ ${RESTORE} == "true" ]]; then
    echo "Restoring backups from ${BUCKET_URL}"
    duplicity ${NO_ENCRYPTION} --file-prefix-manifest manifest- --force restore ${BUCKET_URL} /backup
else
    echo "Backuping $(ls -l /backup) to ${BUCKET_URL}"
    duplicity ${NO_ENCRYPTION} --allow-source-mismatch --s3-use-new-style --file-prefix-manifest manifest- ${DUPLICITY_FULL_BACKUP_AFTER} /backup "${BUCKET_URL}"

    if [[ -n ${DAY_BEFORE_REMOVING_OLD_BACKUP} ]]; then
        echo "Removing backup older than ${DAY_BEFORE_REMOVING_OLD_BACKUP} on ${BUCKET_URL}"
        duplicity --force --allow-source-mismatch --file-prefix-manifest manifest- --s3-use-new-style remove-older-than ${DAY_BEFORE_REMOVING_OLD_BACKUP} ${BUCKET_URL}
    fi
fi