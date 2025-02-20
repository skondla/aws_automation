shost=cp-prod-pamigrate-new-cluster.cluster-abcfr72fgsg3w.us-west-2.rds.amazonaws.com
sport=3306
suser=custusr
spassword=ott_perf2_custusr_db_password
sdatabase=custusr
thost=custusr-pa-migration.cluster-abcfr72fgsg3w.us-west-2.rds.amazonaws.com
tport=5432
tuser=prod_multi_app
tpassword=custusr-migration-pa
tdatabase=prod_multi
region=us-west-2
squery=select subscriberIdentityGuid, 'default', assetGuid,bookmarkSecs,UNIX_TIMESTAMP(lastUpdated) as lastUpdated from StreamedAsset where lastUpdated > date_sub(now(), interval 26 week ) and lastUpdated <= date_sub(now(), interval 25 week)
