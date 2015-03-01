﻿

--Sp_GetFeeds 1

CREATE  proc [dbo].[Sp_GetFeedsForWeb]  

AS  
BEGIN  
 
	--DECLARE @RowsPerPage INT--, @PageNumber INT = 2
	--SELECT @RowsPerPage = ConfigurationValue FROM configuration (nolock)	WHERE ConfigurationName ='PageSize'
	
	--SET @PageNumber = ISNULL(@PageNumber, 1)
	Declare @readmoreText varchar(100)
	set @readmoreText  = ''
	--SELECT *
	--FROM (
	SELECT ISNULL(Feed.FeedID, '') as FeedID  
	,ISNULL(Feed.Title, '') as Title  
	,ISNULL(Feed.ImageURL, '') as imageurl  
	,rtrim(ltrim(substring(ISNULL(Feed.Description, ''),0,300))) --adding case for description if blank
		+ CASE
			When len(ltrim(rtrim(ISNULL(Feed.Description,''))))>10 THEN @readmoreText 
			ELSE '' END  as description  
	,ISNULL(Feed.PublishDate, '') as publishdate  
	,ISNULL(Feed.UTCPublishDate, '') as UTCPublishDate 
	--,dbo.fn_GetTimeDiffference(Feed.PublishDate, getutcdate()) as pubtime  
	,ISNULL(source.SourceName, '') as sourcename  
	--,ISNULL(source.SourceURL, '') as sourceurl  
	,ISNULL(source.LogoURL, '') as logourl  
	--,'From: '+ ISNULL(source.SourceName, '') + ' on ' + convert(varchar(50),ISNULL(Feed.PublishDate, '')) as sourcefrom,
	,'From: '+ ISNULL(source.SourceName, '') + '  ' + REPLACE(dbo.fn_GetTimeDiffference(Feed.UTCPublishDate, getutcdate()),'-','') + ' ago' as sourcefrom,
	ROW_NUMBER() OVER (ORDER BY Feed.UTCPublishDate DESC) AS RowNum
	FROM Feeds (nolock) As Feed 
	INNER JOIN FeedSource (nolock) as source on Feed.Source = source.FeedSourceID  
	Where ISNull(Feed.Active,1) = 1--) AS Feed
	ORDER BY Feed.UTCPublishDate DESC
	--WHERE Feed.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
	--AND @RowsPerPage*(@PageNumber)
	--ORDER BY Feed.UTCPublishDate DESC
	--FOR XML AUTO, ROOT('Feeds'),TYPE, ELEMENTS  
	
	--IF(@PageNumber = 1 AND ISNULL(@DeviceID,'') != '')
	--BEGIN
	--	Declare @RequestedMaxFeedID bigint
		
	--	--SELECT @RequestedMaxFeedID = MAX(id)
	--	--FROM (
	--	--SELECT ISNULL(Feed.ID, '') as id  ,
	--	--ROW_NUMBER() OVER (ORDER BY Feed.ID DESC) AS RowNum
	--	--FROM Feeds As Feed 
	--	--INNER JOIN FeedSource as source on Feed.Source = source.Id  
	--	--Where ISNull(Feed.Active,1) = 1) AS Feed
	--	--WHERE Feed.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
	--	--AND @RowsPerPage*(@PageNumber)
		
	--	SELECT Top 1 @RequestedMaxFeedID =Feed.FeedID
	--	FROM Feeds (nolock) Feed
	--	INNER JOIN FeedSource (nolock) as source on Feed.Source = source.FeedSourceID  
	--	Where ISNull(Feed.Active,1) = 1 AND source.Active= 1
	--	ORDER BY UTCPublishDate DESC 
	--	--update MAXFeedID: used in sending notification 
	--	UPDATE DeviceConfig SET MaxFeedID = @RequestedMaxFeedID,UpdatedDate = GETUTCDATE() where DeviceID = @DeviceID
		
	--END
	
	--IF(@PageNumber IS NOT NULL AND @DeviceID IS NOT NULL)
	--BEGIN
	--	Declare @DeviceConfigID int
	--	SET @DeviceConfigID = 0
	--	Select @DeviceConfigID = ISNULL(DeviceConfigID,0) from DeviceConfig (nolock) where DeviceID = @DeviceID
	--	IF(@DeviceConfigID != 0)
	--		INSERT INTO FeedAuditLog (DeviceConfigID,PageNumber,CreatedDate) VALUES(@DeviceConfigID, @PageNumber, GETUTCDATE())
	--END
END



