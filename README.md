# Mongorestore - S3

The mongorestore container is designed to allow the restore of either a full or partial mongodatabase from a S3 backup it can also list available backups.

The container has a script in the /backup folder called run which has to be run manually as a saftey precaution to avoid faulty rollbacks. The backup folder will also be the working directory when connection to the docker container. Running the script will give you four options.

* **Latest** - Will do a full restore from the most previous backup found in the S3 folder
* **List** - Lists all the backups from the folder.
* **Pick** - Allows you to specify which backup to run. Use list first to get a list of backup to choose from.
* **Catalog** - Allows you to restore a specific catalog from a database.

***Note that the restore will always be performed against a primary member of the cluster***

### Environmental variables & Service link

You need five environmental variables for the backup script to work.

| Variable | Value |
| ------ | ------ |
| AWS_ACCESS_KEY_ID | Your key id. |
| AWS_SECRET_ACCESS_KEY | Your secret access key |
| FILEPREFIX | the filename prefix |
| S3BUCKET | The name of your Amazon S3 Bucket to restore the backup from. |

You are also required to setup a service link To link your mongodb backup container to the mongodatabase. Add a service link in rancher by using the name "mongo" e.g mongo-cluster -> mongo

### catalog ###
You will be prompted if you want to restore the latest backup or pick a backup file from the list by using the full name (e.g mongodb.backup.PROD.2017-07-20-12-36-59.tar.gz). After the backup has been picked the archive will be downloaded and unzipped. After that the contents of the /dump folder will be listed and you will be able to pick which database you want to restore a catalog from. After picking a database all the available catalogs will be listed. You must then specify the ***.bson*** file you want to use. You ***MUST*** select a .bson file and not the .json file or the restore wont work.

### latest ###
Always picks the latest backup in the list of backups. By executing
```sh
: ${FILE:=$(aws s3 ls s3://$S3BUCKET | awk -F " " '{print $4}' | grep ^$FILEPREFIX | sort -r | head -n1)}
```
### list ###
Connects to the S3 bucket to query a list of all the backups in the list and outputs as a table.
```sh
  aws s3api list-objects --bucket $S3BUCKET --query 'Contents[].{Key: Key, Size: Size}' --output table
  ```
### pick ###
Allows you to pick a backup to be restored from the list. Must define the full filename (e.g mongodb.backup.PROD.2017-07-20-12-36-59.tar.gz)
