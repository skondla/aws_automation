shost=cp-prod-pamigrate-parallal-replica1.ct2oghm9eyns.eu-west-1.rds.amazonaws.com
sport=3302
suser=cloffice
spassword=ott_perf2_cloffice_db_password
sdatabase=cloffice
thost=cloffice-pa-migration.cluster-ct2oghm9eyns.eu-west-1.rds.amazonaws.com
tport=5432
tuser=weeklyapp
tpassword=cloffice-migration-pa
tdatabase=weekly
region=eu-west-1
squery=select subscriberIdentityGuid, 'default', tenantId, assetGuid,bookmarkSecs,UNIX_TIMESTAMP(lastUpdated) as lastUpdated from PlayedAsset where lastUpdated > date_sub(now(), interval 180 day ) and lastUpdated <= date_sub(now(), interval 173 day);
tag=copybookmarks_prod_week1
