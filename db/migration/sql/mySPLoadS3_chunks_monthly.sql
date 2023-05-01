DROP PROCEDURE IF EXISTS loadPA2S3_chunks_monthly;
DELIMITER $$
CREATE PROCEDURE loadPA2S3_chunks_monthly(
	IN mnth INT, 
	IN mnthyear INT)
READS SQL DATA
BEGIN
	DECLARE cursor_finished INT DEFAULT 0;
	DECLARE v_subscriberGuid varchar(255);
	DECLARE v_month INT;
	DECLARE v_monthyear VARCHAR(6);
	DECLARE cursor_dist_subsc CURSOR FOR 
	select distinct subscriberIdentityGuid from ViewedAsset USE INDEX (idx_ViewedAsset_lastUpdated)
	where date_format(date_sub(lastUpdated , interval v_month month ),'%Y%m') = v_monthyear
	and subscriberIdentityGuid is not null;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_finished = 1;
	
	SET v_month = mnth;
	SET v_monthyear = mnthyear;
	/*SET v_monthyear = CONCAT('\'',mnthyear, '\'') ; */
	
	SELECT v_month;
	SELECT v_monthyear;
	
  OPEN cursor_dist_subsc;
  read_loop: LOOP
  FETCH cursor_dist_subsc INTO v_subscriberGuid; 
	SET  @v_subscriberGuid = v_subscriberGuid;
	/*SELECT @v_subscriberGuid;*/
  /*CALL cloffice.`uploadsubGuidtoS3_nochunk`(@`v_subscriberGuid`);*/
	SET @v_subscriberGuid1 = CONCAT('\'',@v_subscriberGuid, '\'') ;
	SET @s3URL := 's3-eu-west-1://cp-bookmark-from-sql-to-s3-monthly-test2/', @fileAlias := @v_subscriberGuid, @profile := '/default/', @fileName := 'bookmarks.txt';
	SET @s3URL = CONCAT(@s3URL,@fileAlias,@profile,@fileName);
	SET @s3URL = CONCAT('\'',@s3URL, '\'') ;
	set @sql = CONCAT('select `assetGuid` as asset_id, `bookmarkSecs` as position, UNIX_TIMESTAMP(`lastUpdated`) as position_epoch 
			from ViewedAsset where `subscriberIdentityGuid` = ', @v_subscriberGuid1, ' INTO OUTFILE S3 ', @s3URL ,
			' FIELDS TERMINATED BY '','' 
			LINES TERMINATED BY ''\\n'' 
			OVERWRITE ON');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
  IF cursor_finished = 1 THEN LEAVE read_loop; END IF;
  END LOOP;
  CLOSE cursor_dist_subsc;
END $$
DELIMITER ;