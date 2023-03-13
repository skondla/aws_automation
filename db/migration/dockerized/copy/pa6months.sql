select count(*) from PlayedAsset where lastUpdated > date_sub(now(), interval 6 month);
