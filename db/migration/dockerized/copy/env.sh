shost=cp-prod-pamigrate-new-cluster.cluster-ct2oghm9eyns.eu-west-1.rds.amazonaws.com
sport=3306
suser=cloffice
spassword=ott_perf2_cloffice_db_password
sdatabase=cloffice
thost=cloffice-pa-migration.cluster-ct2oghm9eyns.eu-west-1.rds.amazonaws.com
tport=5432
tuser=prod_multi_app
tpassword=cloffice-migration-pa
tdatabase=prod_multi
region=eu-west-1
squery=select subscriberIdentityGuid, 'default', assetGuid,bookmarkSecs,UNIX_TIMESTAMP(lastUpdated) as lastUpdated from StreamedAsset where lastUpdated > date_sub(now(), interval 26 week ) and lastUpdated <= date_sub(now(), interval 25 week)
