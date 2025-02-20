shost=cp-prod-pamigrate-parallal-replica1.abcfr72fgsg3w.us-west-2.rds.amazonaws.com
sport=3302
suser=custusr
spassword=ott_perf2_custusr_db_password
sdatabase=custusr
thost=custusr-pa-migration.cluster-abcfr72fgsg3w.us-west-2.rds.amazonaws.com
tport=5432
tuser=weeklyapp
tpassword=custusr-migration-pa
tdatabase=weekly
region=us-west-2
#squery1=select distinct(subscriberIdentityGuid) from StreamedAsset where lastUpdated > date_sub(now(), interval 180 day ) and lastUpdated <= date_sub(now(), interval 173 day)
#squery1=select distinct(subscriberIdentityGuid) from StreamedAsset where lastUpdated > date_sub(now(), interval 180 day ) and lastUpdated <= date_sub(now(), interval 173 day) and subscriberIdentityGuid is not null
squery1=select subscriberIdentityGuid from StreamedAsset where lastUpdated > date_sub(now(), interval 180 day ) and lastUpdated <= date_sub(now(), interval 173 day) and subscriberIdentityGuid is not null
squery2=select assetGuid as asset_id, bookmarkSecs as position, UNIX_TIMESTAMP(lastUpdated) as position_epoch from StreamedAsset where subscriberIdentityGuid = %s
tag=loadbookmarks_prod_week1
