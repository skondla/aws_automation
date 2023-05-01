select count(*) from ViewedAsset where lastUpdated > date_sub(now(), interval 6 month);
