DROP TABLE IF EXISTS smoke_test_report;
CREATE TABLE smoke_test_report (stepId INT PRIMARY KEY auto_increment, errorCount int , errorMsg TEXT, passFlag VARCHAR(10),sqlStatement TEXT);
##############################################################################################################################################
#
#                                                    GAIS smoket test
#  IM-1213   solicitation_stewardship   solicitations
#
##############################################################################################################################################
#activity
##############################################################################################################################################
INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT a.description,a.result,SUM(a.number),"SELECT * FROM z_newcreate_template_gais WHERE CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND LENGTH(TRIM(gaisLegacyId))>0 GROUP BY gaisLegacyId,sourceTable,gaisLegacyIdSeq HAVING COUNT(*)>1) ORDER BY CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq);" FROM (SELECT ''Duplicate legacyId in Activity'' description,IF(COUNT(*)>0,''Fail'',''Pass'') result,COUNT(*) number FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND LENGTH(TRIM(gaisLegacyId))>0 GROUP BY gaisLegacyId,sourceTable,gaisLegacyIdSeq HAVING COUNT(*)>1) a;

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Invalid link account id in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND CONCAT_WS(''#'',accountLinkingId,accountLinkingSeq,accountLinkingIdSourceTable) NOT IN(SELECT CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable) FROM z_newcreate_template_basic_account_info WHERE LENGTH(TRIM(CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable)))>0 AND masterRecord=1);" FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND CONCAT_WS(''#'',accountLinkingId,accountLinkingSeq,accountLinkingIdSourceTable) NOT IN(SELECT CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable) FROM z_newcreate_template_basic_account_info WHERE LENGTH(TRIM(CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable)))>0 AND masterRecord=1);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Link account id is blank in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND (accountLinkingId IS NULL OR LENGTH(TRIM(accountLinkingId))=0);" FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND (accountLinkingId IS NULL OR LENGTH(TRIM(accountLinkingId))=0);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''The transation type is blank or not a standard values'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType IS NULL OR parentType NOT IN(''Activity'',''Grants'',''Invitation'',''Prospects'');" FROM z_newcreate_template_gais WHERE parentType IS NULL OR parentType NOT IN(''Activity'',''Grants'',''Invitation'',''Prospects'');

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''The start date is bigger than end date in Activity'',IF(COUNT(*)>0,''Warning'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE activityStartDate IS NOT NULL AND activityEndDate IS NOT NULL AND  activityStartDate>activityEndDate;" FROM z_newcreate_template_gais WHERE activityStartDate IS NOT NULL AND activityEndDate IS NOT NULL AND  activityStartDate>activityEndDate;

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Subject and StartDate must be populated in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND (LENGTH(TRIM(activitySubject))=0 OR activitySubject IS NULL OR LENGTH(TRIM(activityStartDate))=0 OR activityStartDate IS NULL);" FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND (LENGTH(TRIM(activitySubject))=0 OR activitySubject IS NULL OR LENGTH(TRIM(activityStartDate))=0 OR activityStartDate IS NULL);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Priority is not a standard value in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND LENGTH(TRIM(activityPriority))>0 AND activityPriority NOT IN(''High'',''Low'',''Normal'');" FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND LENGTH(TRIM(activityPriority))>0 AND activityPriority NOT IN(''High'',''Low'',''Normal'');

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Priority is blank, and we will set it as normal in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND (LENGTH(TRIM(activityPriority))=0 OR activityPriority IS NULL);" FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND (LENGTH(TRIM(activityPriority))=0 OR activityPriority IS NULL);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Status is not a standard value in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND LENGTH(TRIM(activityStatus))>0 AND activityStatus NOT IN(''Not Started'',''In Progress'',''Completed'',''Waiting For Others'',''Deferred'',''Deferred'',''Other'');" FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND LENGTH(TRIM(activityStatus))>0 AND activityStatus NOT IN(''Not Started'',''In Progress'',''Completed'',''Waiting For Others'',''Deferred'',''Deferred'',''Other'');

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Status is blank, and we will set it as completed in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND (LENGTH(TRIM(activityStatus))=0 OR activityStatus IS NULL);" FROM z_newcreate_template_gais WHERE parentType=''Activity'' AND (LENGTH(TRIM(activityStatus))=0 OR activityStatus IS NULL);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''If the row is activity, then the activityLinkedGrantLegacyId, activityLinkedProspectLegacyId and activityLinkedInvitationLegacyId only populated one column'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType IN(''Activity'') AND (LENGTH(TRIM(activityLinkedGrantLegacyId))>0 AND LENGTH(TRIM(activityLinkedProspectLegacyId))>0) OR (LENGTH(TRIM(activityLinkedProspectLegacyId))>0 AND LENGTH(TRIM(activityLinkedInvitationLegacyId))>0) OR (LENGTH(TRIM(activityLinkedGrantLegacyId))>0 AND LENGTH(TRIM(activityLinkedInvitationLegacyId))>0);" FROM z_newcreate_template_gais WHERE parentType IN(''Activity'') AND (LENGTH(TRIM(activityLinkedGrantLegacyId))>0 AND LENGTH(TRIM(activityLinkedProspectLegacyId))>0) OR (LENGTH(TRIM(activityLinkedProspectLegacyId))>0 AND LENGTH(TRIM(activityLinkedInvitationLegacyId))>0) OR (LENGTH(TRIM(activityLinkedGrantLegacyId))>0 AND LENGTH(TRIM(activityLinkedInvitationLegacyId))>0);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''If the row is not activity, then the activityLinkedGrantLegacyId, activityLinkedProspectLegacyId and activityLinkedInvitationLegacyId must be blank'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType IN(''Invitation'',''Prospects'',''Grants'') AND (LENGTH(TRIM(activityLinkedGrantLegacyId))>0 OR LENGTH(TRIM(activityLinkedProspectLegacyId))>0 OR LENGTH(TRIM(activityLinkedInvitationLegacyId))>0);" FROM z_newcreate_template_gais WHERE parentType IN(''Invitation'',''Prospects'',''Grants'') AND (LENGTH(TRIM(activityLinkedGrantLegacyId))>0 OR LENGTH(TRIM(activityLinkedProspectLegacyId))>0 OR LENGTH(TRIM(activityLinkedInvitationLegacyId))>0);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Invalid activityLinkedGrantLegacyId in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE LENGTH(TRIM(activityLinkedGrantLegacyId))>0 AND parentType=''Activity'' AND CONCAT_WS(''#'',activityLinkedGrantLegacyId,activityLinkedGrantLegacyIdSourceTable,activityLinkedGrantLegacyIdSeq) NOT IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Grants'');" FROM z_newcreate_template_gais WHERE LENGTH(TRIM(activityLinkedGrantLegacyId))>0 AND parentType=''Activity'' AND CONCAT_WS(''#'',activityLinkedGrantLegacyId,activityLinkedGrantLegacyIdSourceTable,activityLinkedGrantLegacyIdSeq) NOT IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Grants'');

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Invalid activityLinkedInvitationLegacyId in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE LENGTH(TRIM(activityLinkedInvitationLegacyId))>0 AND parentType=''Activity'' AND CONCAT_WS(''#'',activityLinkedInvitationLegacyId,activityLinkedInvitationLegacyIdSourceTable,activityLinkedInvitationLegacyIdSeq) NOT IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Invitation'');" FROM z_newcreate_template_gais WHERE LENGTH(TRIM(activityLinkedInvitationLegacyId))>0 AND parentType=''Activity'' AND CONCAT_WS(''#'',activityLinkedInvitationLegacyId,activityLinkedInvitationLegacyIdSourceTable,activityLinkedInvitationLegacyIdSeq) NOT IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Invitation'');

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Invalid activityLinkedProspectLegacyId in Activity'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE LENGTH(TRIM(activityLinkedProspectLegacyId))>0 AND parentType=''Activity'' AND CONCAT_WS(''#'',activityLinkedProspectLegacyId,activityLinkedProspectLegacyIdSourceTable,activityLinkedProspectLegacyIdSeq) NOT IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Prospects'');" FROM z_newcreate_template_gais WHERE LENGTH(TRIM(activityLinkedProspectLegacyId))>0 AND parentType=''Activity'' AND CONCAT_WS(''#'',activityLinkedProspectLegacyId,activityLinkedProspectLegacyIdSourceTable,activityLinkedProspectLegacyIdSeq) NOT IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Prospects'');

##############################################################################################################################################
#grant
##############################################################################################################################################
INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT a.description,a.result,SUM(a.number),"SELECT * FROM z_newcreate_template_gais WHERE CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND LENGTH(TRIM(gaisLegacyId))>0 GROUP BY gaisLegacyId,sourceTable,gaisLegacyIdSeq HAVING COUNT(*)>1) ORDER BY CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq);" FROM (SELECT ''Duplicate legacyId in Grants'' description,IF(COUNT(*)>0,''Fail'',''Pass'') result,COUNT(*) number FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND LENGTH(TRIM(gaisLegacyId))>0 GROUP BY gaisLegacyId,sourceTable,gaisLegacyIdSeq HAVING COUNT(*)>1) a;

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Invalid link account id in Grant'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND CONCAT_WS(''#'',accountLinkingId,accountLinkingSeq,accountLinkingIdSourceTable) NOT IN(SELECT CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable) FROM z_newcreate_template_basic_account_info WHERE LENGTH(TRIM(CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable)))>0 AND masterRecord=1);" FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND CONCAT_WS(''#'',accountLinkingId,accountLinkingSeq,accountLinkingIdSourceTable) NOT IN(SELECT CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable) FROM z_newcreate_template_basic_account_info WHERE LENGTH(TRIM(CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable)))>0 AND masterRecord=1);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Link account id is blank in Grant'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND (accountLinkingId IS NULL OR LENGTH(TRIM(accountLinkingId))=0);" FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND (accountLinkingId IS NULL OR LENGTH(TRIM(accountLinkingId))=0);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Due date must be populated in Grant'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND (LENGTH(TRIM(grantDueDate))=0 OR grantDueDate IS NULL);" FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND (LENGTH(TRIM(grantDueDate))=0 OR grantDueDate IS NULL);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Status is not a standard value in Grants'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND LENGTH(TRIM(grantStatus))>0 AND grantStatus NOT IN(''Not Started'',''Prepare'',''Pending'',''Closed - Funded'',''Deferred'',''Closed - Declined'');" FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND LENGTH(TRIM(grantStatus))>0 AND grantStatus NOT IN(''Not Started'',''Prepare'',''Pending'',''Closed - Funded'',''Deferred'',''Closed - Declined'');

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Status is blank, and we will set it as closed - funded in Grants'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND (LENGTH(TRIM(grantStatus))=0 OR grantStatus IS NULL);" FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND (LENGTH(TRIM(grantStatus))=0 OR grantStatus IS NULL);

#if we edit the ask amount then we can set a negative number
INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Grant ask amount must be a positive number'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND LENGTH(TRIM(grantAskAmount))>0 AND grantAskAmount<0;" FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND LENGTH(TRIM(grantAskAmount))>0 AND grantAskAmount<0;

#if we edit the funded amount then we can set a negative number
INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Grant funded amount must be a positive number'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND LENGTH(TRIM(grantFundedAmount))>0 AND grantFundedAmount<0;" FROM z_newcreate_template_gais WHERE parentType=''Grants'' AND LENGTH(TRIM(grantFundedAmount))>0 AND grantFundedAmount<0;

##############################################################################################################################################
#invitation
##############################################################################################################################################
INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT a.description,a.result,SUM(a.number),"SELECT * FROM z_newcreate_template_gais WHERE CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND LENGTH(TRIM(gaisLegacyId))>0 GROUP BY gaisLegacyId,sourceTable,gaisLegacyIdSeq HAVING COUNT(*)>1) ORDER BY CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq);" FROM (SELECT ''Duplicate legacyId in Invitation'' description,IF(COUNT(*)>0,''Fail'',''Pass'') result,COUNT(*) number FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND LENGTH(TRIM(gaisLegacyId))>0 GROUP BY gaisLegacyId,sourceTable,gaisLegacyIdSeq HAVING COUNT(*)>1) a;

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Invalid link account id in Invitation'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND CONCAT_WS(''#'',accountLinkingId,accountLinkingSeq,accountLinkingIdSourceTable) NOT IN(SELECT CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable) FROM z_newcreate_template_basic_account_info WHERE LENGTH(TRIM(CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable)))>0 AND masterRecord=1);" FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND CONCAT_WS(''#'',accountLinkingId,accountLinkingSeq,accountLinkingIdSourceTable) NOT IN(SELECT CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable) FROM z_newcreate_template_basic_account_info WHERE LENGTH(TRIM(CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable)))>0 AND masterRecord=1);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Link account id is blank in Invitation'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND (accountLinkingId IS NULL OR LENGTH(TRIM(accountLinkingId))=0);" FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND (accountLinkingId IS NULL OR LENGTH(TRIM(accountLinkingId))=0);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Invite Date and Event must be populated in Invitation'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND (invitationInviteDate IS NULL OR invitationEvent IS NULL OR LENGTH(TRIM(invitationInviteDate))=0 OR LENGTH(TRIM(invitationEvent))=0);" FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND (invitationInviteDate IS NULL OR invitationEvent IS NULL OR LENGTH(TRIM(invitationInviteDate))=0 OR LENGTH(TRIM(invitationEvent))=0);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Status is not a standard value in Invitation'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND LENGTH(TRIM(invitationStatus))>0 AND invitationStatus NOT IN(''Not Started'',''In Progress'',''Closed - Accepted'',''Closed - Declined'');" FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND LENGTH(TRIM(invitationStatus))>0 AND invitationStatus NOT IN(''Not Started'',''In Progress'',''Closed - Accepted'',''Closed - Declined'');

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Status is blank, and we will set it as closed - accepted in Invitation'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND (LENGTH(TRIM(invitationStatus))=0 OR invitationStatus IS NULL);" FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND (LENGTH(TRIM(invitationStatus))=0 OR invitationStatus IS NULL);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Invitation event name not exist in event'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND LENGTH(TRIM(invitationEvent))>0 AND invitationEvent NOT IN(SELECT name FROM event);" FROM z_newcreate_template_gais WHERE parentType=''Invitation'' AND LENGTH(TRIM(invitationEvent))>0 AND invitationEvent NOT IN(SELECT name FROM event);

##############################################################################################################################################
#prospects
##############################################################################################################################################
INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT a.description,a.result,SUM(a.number),"SELECT * FROM z_newcreate_template_gais WHERE CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) IN(SELECT CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq) FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND LENGTH(TRIM(gaisLegacyId))>0 GROUP BY gaisLegacyId,sourceTable,gaisLegacyIdSeq HAVING COUNT(*)>1) ORDER BY CONCAT_WS(''#'',gaisLegacyId,sourceTable,gaisLegacyIdSeq);" FROM (SELECT ''Duplicate legacyId in Prospects'' description,IF(COUNT(*)>0,''Fail'',''Pass'') result,COUNT(*) number FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND LENGTH(TRIM(gaisLegacyId))>0 GROUP BY gaisLegacyId,sourceTable,gaisLegacyIdSeq HAVING COUNT(*)>1) a;

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Invalid link account id in Prospects'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND CONCAT_WS(''#'',accountLinkingId,accountLinkingSeq,accountLinkingIdSourceTable) NOT IN(SELECT CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable) FROM z_newcreate_template_basic_account_info WHERE LENGTH(TRIM(CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable)))>0 AND masterRecord=1);" FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND CONCAT_WS(''#'',accountLinkingId,accountLinkingSeq,accountLinkingIdSourceTable) NOT IN(SELECT CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable) FROM z_newcreate_template_basic_account_info WHERE LENGTH(TRIM(CONCAT_WS(''#'',mainAccountLinkingId,accountSequence,sourceTable)))>0 AND masterRecord=1);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Link account id is blank in Prospects'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND (accountLinkingId IS NULL OR LENGTH(TRIM(accountLinkingId))=0);" FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND (accountLinkingId IS NULL OR LENGTH(TRIM(accountLinkingId))=0);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Ask Date must be populated in Prospects'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND (prospectAskDate IS NULL OR LENGTH(TRIM(prospectAskDate))=0);" FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND (prospectAskDate IS NULL OR LENGTH(TRIM(prospectAskDate))=0);

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Status is not a standard value in Prospects'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND LENGTH(TRIM(prospectStatus))>0 AND prospectStatus NOT IN(''Not Started'',''In Progress'',''Closed - Won'',''Closed - Lost'');" FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND LENGTH(TRIM(prospectStatus))>0 AND prospectStatus NOT IN(''Not Started'',''In Progress'',''Closed - Won'',''Closed - Lost'');

INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Status is blank, and we will set it as closed - won in in Prospects'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND (LENGTH(TRIM(prospectStatus))=0 OR prospectStatus IS NULL);" FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND (LENGTH(TRIM(prospectStatus))=0 OR prospectStatus IS NULL);

#if we edit the ask amount then we can set a negative number
INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Prospects ask amount must be a positive number'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND LENGTH(TRIM(prospectAskAmount))>0 AND prospectAskAmount<0;" FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND LENGTH(TRIM(prospectAskAmount))>0 AND prospectAskAmount<0;

#if we edit the pledge amount then we can set a negative number
INSERT INTO smoke_test_report(errorMsg,passFlag,errorCount,sqlStatement)
SELECT ''Prospects pledge amount must be a positive number'',IF(COUNT(*)>0,''Fail'',''Pass''),COUNT(*),"SELECT * FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND LENGTH(TRIM(prospectPledgeAmount))>0 AND prospectPledgeAmount<0;" FROM z_newcreate_template_gais WHERE parentType=''Prospects'' AND LENGTH(TRIM(prospectPledgeAmount))>0 AND prospectPledgeAmount<0;
