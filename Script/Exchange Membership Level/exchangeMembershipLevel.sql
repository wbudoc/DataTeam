###################################################################################################################################
#
#                                                        INT-153
#                                在执行下面的脚本之前需要先看INT-153上面的description,进行一些验证
#
###################################################################################################################################
DROP PROCEDURE IF EXISTS dt_membership_discount;

delimiter //
CREATE DEFINER=`root`@`%` PROCEDURE dt_membership_discount()
BEGIN
SELECT IF(COUNT(*)>0,COUNT(*),0) INTO @itemName FROM discount WHERE itemName='Any membership';

IF @itemName>=1 THEN
	UPDATE z_newcreate_exchange_membership SET existDiscount=1;
ELSE
	UPDATE z_newcreate_exchange_membership zn,discount d,membership_listing ml SET zn.existDiscount=1 WHERE zn.from_membershipListingId=ml.id AND (ml.couponCode IS NOT NULL OR ml.membershipTermId=d.itemId) AND zn.from_membershipListingId IS NOT NULL;

END IF;
END //

delimiter ;

###################################################################################################################################
DROP TABLE IF EXISTS
z_newcreate_exchange_membership,
z_newcreate_exchange_membership1,
z_newcreate_exchange_membership2,
z_newcreate_exchange_membership3,
z_newcreate_exchange_membership4,
z_newcreate_exchange_membership_spec,
z_newcreate_exchange_membership_spec1,
z_newcreate_ignore_membership_discount,
z_newcreate_a_part_membership_spec,
z_newcreate_one_to_more;

###################################################################################################################################
#Create Exchange Membership
###################################################################################################################################
CREATE TABLE z_newcreate_exchange_membership(
from_membershipListingId INT DEFAULT NULL,
to_membershipLevel VARCHAR(100) DEFAULT NULL,
to_membershipGroup INT DEFAULT NULL);

###################################################################################################################################
#Insert into data
###################################################################################################################################
INSERT INTO z_newcreate_exchange_membership(from_membershipListingId,to_membershipLevel,to_membershipGroup)
SELECT id,'','' FROM membership_listing WHERE membershipId IN();

###################################################################################################################################
#confirm whether from_membershipLevel exist discount
###################################################################################################################################
ALTER TABLE z_newcreate_exchange_membership ADD COLUMN existDiscount INT DEFAULT NULL;

CALL dt_membership_discount();
DROP PROCEDURE IF EXISTS dt_membership_discount;

CREATE TABLE z_newcreate_ignore_membership_discount
SELECT * FROM membership_listing WHERE (accountId,membershipId) IN(
SELECT accountId,membershipId FROM membership_listing WHERE id IN(SELECT from_membershipListingId FROM z_newcreate_exchange_membership WHERE existDiscount=1));

UPDATE z_newcreate_exchange_membership zn,z_newcreate_ignore_membership_discount zn2 SET zn.existDiscount=1 WHERE zn.from_membershipListingId=zn2.id;

###################################################################################################################################
#Create New Membership Level
###################################################################################################################################
ALTER TABLE z_newcreate_exchange_membership
ADD COLUMN needCreate INT DEFAULT 0,
ADD COLUMN from_membershipId INT DEFAULT NULL,
ADD COLUMN to_membershipId INT DEFAULT NULL;

UPDATE z_newcreate_exchange_membership SET needCreate=1 WHERE (to_membershipLevel,to_membershipGroup) NOT IN(SELECT description,groupMembershipType FROM membership);

SELECT MAX(displayOrder+0) INTO @membership_display_order FROM membership;
INSERT INTO membership(description,dataStatus,groupMembershipType,displayOrder,createBy,createTime,lastModifyBy,lastModifyTime)
SELECT to_membershipLevel,1,to_membershipGroup,@membership_display_order:=@membership_display_order+1,'Neon Custom Import',NOW(),'Neon Custom Import',NOW() FROM z_newcreate_exchange_membership WHERE needCreate=1 GROUP BY to_membershipLevel,to_membershipGroup;

###################################################################################################################################
#confirm whether one to_membershipLevel matched more membershipLevel
###################################################################################################################################
CREATE TABLE z_newcreate_one_to_more
SELECT * FROM membership WHERE (description,groupMembershipType) IN(SELECT to_membershipLevel,to_membershipGroup FROM z_newcreate_exchange_membership) GROUP BY description,groupMembershipType HAVING COUNT(*)>1;

UPDATE z_newcreate_exchange_membership zn1,z_newcreate_one_to_more zn2 SET zn1.needCreate=2 WHERE zn1.to_membershipLevel=zn2.description AND zn1.to_membershipGroup=zn2.groupMembershipType;

###################################################################################################################################
#add new membership level
###################################################################################################################################
UPDATE z_newcreate_exchange_membership zn,membership m SET zn.to_membershipId=m.id WHERE zn.to_membershipLevel=m.description AND zn.to_membershipGroup=m.groupMembershipType AND zn.needCreate<>2;
UPDATE z_newcreate_exchange_membership zn,membership_listing ml SET zn.from_membershipId=ml.membershipId WHERE zn.from_membershipListingId=ml.id AND zn.from_membershipListingId IS NOT NULL;

CREATE TABLE membership_term_wulei LIKE membership_term;
INSERT INTO membership_term_wulei(membershipId,display,enrollType,termDuration,termUnit,cost)
SELECT DISTINCT to_membershipId,CONCAT(to_membershipLevel,' Join'),1,1,1,0.00 FROM z_newcreate_exchange_membership WHERE needCreate=1;
INSERT INTO membership_term_wulei(membershipId,display,enrollType,termDuration,termUnit,cost)
SELECT DISTINCT to_membershipId,CONCAT(to_membershipLevel,' Renew'),2,1,1,0.00 FROM z_newcreate_exchange_membership WHERE needCreate=1;

SELECT MAX(displayOrder+0) INTO @membership_term_display_order FROM membership_term;
INSERT INTO membership_term(membershipId,display,enrollType,termDuration,termUnit,cost,displayOrder)
SELECT membershipId,display,enrollType,termDuration,termUnit,cost,@membership_term_display_order:=@membership_term_display_order+1 FROM membership_term_wulei ORDER BY display;

DROP TABLE membership_term_wulei;

UPDATE membership_term mt1,membership_term mt2 SET mt1.pairedTermId=mt2.id WHERE mt1.membershipId=mt2.membershipId AND mt1.enrollType<>mt2.enrollType AND mt1.parentMembershipTermId IS NULL AND mt2.parentMembershipTermId IS NULL;

###################################################################################################################################
#confirm whether from_membershipLevel exist sub membership
###################################################################################################################################
CREATE TABLE z_newcreate_exchange_membership1
SELECT * FROM z_newcreate_exchange_membership WHERE needCreate<>2 AND from_membershipId IS NOT NULL AND existDiscount IS NULL;

ALTER TABLE z_newcreate_exchange_membership1 ADD COLUMN isSubMember INT DEFAULT NULL;

UPDATE z_newcreate_exchange_membership1 zn,membership_listing ml SET zn.isSubMember=1 WHERE zn.from_membershipListingId=ml.id AND ml.membershipGroupParentId IS NOT NULL AND zn.from_membershipListingId IS NOT NULL;
UPDATE z_newcreate_exchange_membership1 zn,membership_listing ml,membership_listing ml1 SET zn.isSubMember=1 WHERE zn.from_membershipListingId=ml.id AND ml.membershipGroupParentId IS NULL AND ml1.membershipGroupParentId IS NOT NULL AND ml.id=ml1.membershipGroupParentId AND zn.from_membershipListingId IS NOT NULL;

###################################################################################################################################
#confirm whether from_membershipLevel exist membership spec
###################################################################################################################################
CREATE TABLE z_newcreate_exchange_membership2
SELECT * FROM z_newcreate_exchange_membership1 WHERE isSubMember IS NULL;

ALTER TABLE z_newcreate_exchange_membership2 ADD COLUMN existMembershipSpec INT DEFAULT NULL;

CREATE TABLE z_newcreate_exchange_membership_spec
SELECT *,membershipId to_membershipId FROM membership_spec WHERE listId IS NULL AND (accountId,membershipId) IN(SELECT ml.accountId,ml.membershipId FROM membership_listing ml JOIN z_newcreate_exchange_membership2 zb2 ON ml.id=zb2.from_membershipListingId)
UNION
SELECT *,membershipId FROM membership_spec WHERE listId IS NULL AND (accountId,membershipId) IN(SELECT ml.accountId,zb2.to_membershipId FROM membership_listing ml JOIN z_newcreate_exchange_membership2 zb2 ON ml.id=zb2.from_membershipListingId);

###########################################################
#对于一个账号有多个
###########################################################
CREATE TABLE z_newcreate_a_part_membership_spec
SELECT ml.accountId,ml.membershipId FROM membership_listing ml
JOIN z_newcreate_exchange_membership2 zb2 ON ml.id=zb2.from_membershipListingId
JOIN membership_listing ml2 ON ml.accountId=ml2.accountId AND ml.membershipId=ml2.membershipId
WHERE ml.id<>ml2.id;

DELETE FROM z_newcreate_exchange_membership_spec WHERE (accountId,membershipId) IN (SELECT accountId,membershipId FROM z_newcreate_a_part_membership_spec);

ALTER TABLE z_newcreate_exchange_membership_spec ADD COLUMN isImport INT DEFAULT 0;

UPDATE z_newcreate_exchange_membership_spec zn,z_newcreate_exchange_membership2 zn2 SET zn.to_membershipId=zn2.to_membershipId WHERE zn.to_membershipId=zn2.from_membershipId;

CREATE TABLE z_newcreate_exchange_membership_spec1
SELECT MAX(id+0) id,accountId,to_membershipId,GROUP_CONCAT(DISTINCT autoRenewal SEPARATOR '###') autoRenewal,GROUP_CONCAT(DISTINCT creditCardId SEPARATOR '###') creditCardId,GROUP_CONCAT(DISTINCT bankAccountId SEPARATOR '###') bankAccountId,1 isImport FROM z_newcreate_exchange_membership_spec GROUP BY accountId,to_membershipId;

UPDATE z_newcreate_exchange_membership_spec1 SET isImport=0 WHERE INSTR(autoRenewal,'###')>0 OR INSTR(creditCardId,'###')>0 OR INSTR(bankAccountId,'###')>0;
UPDATE z_newcreate_exchange_membership_spec1 SET isImport=0 WHERE LENGTH(TRIM(creditCardId))>0 AND LENGTH(TRIM(bankAccountId))>0;
UPDATE z_newcreate_exchange_membership_spec zb1,z_newcreate_exchange_membership_spec1 zb2 SET zb1.isImport=1 WHERE zb1.accountId=zb2.accountId AND zb1.to_membershipId=zb2.to_membershipId AND zb2.isImport=1;

DELETE FROM membership_spec WHERE id IN(SELECT id FROM z_newcreate_exchange_membership_spec WHERE isImport=1);

INSERT INTO membership_spec(id,accountId,membershipId,autoRenewal,creditCardId,bankAccountId,createBy,createTime,lastModifyBy,lastModifyTime)
SELECT id,accountId,to_membershipId,autoRenewal,creditCardId,bankAccountId,'Neon Custom Import',NOW(),'Neon Custom Import',NOW() FROM z_newcreate_exchange_membership_spec1 WHERE isImport=1;

UPDATE z_newcreate_exchange_membership2 zn,(SELECT * FROM membership_listing WHERE (accountId,membershipId) IN(
SELECT accountId,membershipId FROM z_newcreate_exchange_membership_spec WHERE isImport=0
UNION
SELECT accountId,membershipId FROM z_newcreate_a_part_membership_spec)) ms SET zn.existMembershipSpec=1 WHERE zn.from_membershipListingId=ms.id;

###################################################################################################################################
#final exchange membership
###################################################################################################################################
CREATE TABLE z_newcreate_exchange_membership3
SELECT * FROM z_newcreate_exchange_membership2 WHERE existMembershipSpec IS NULL;

UPDATE membership_listing ml,z_newcreate_exchange_membership3 zn2 SET ml.membershipId=zn2.to_membershipId,ml.membershipTermId=NULL WHERE ml.id=zn2.from_membershipListingId;
UPDATE membership_listing ml,membership_term mt SET ml.membershipTermId=mt.id WHERE ml.membershipId=mt.membershipId AND ml.membershipGroupParentId IS NULL AND mt.parentMembershipTermId IS NULL AND ml.membershipTermId IS NULL AND ml.enrollType=mt.enrollType;
UPDATE shopping_cart_items si,(SELECT * FROM membership_listing WHERE id IN(SELECT from_membershipListingId FROM z_newcreate_exchange_membership3)) ml,membership_term mt SET si.name=mt.display WHERE si.membershipEnrollmentId=ml.id AND ml.membershipTermId=mt.id;
UPDATE membership_spec ms,z_newcreate_exchange_membership3 zn SET ms.membershipId=zn.to_membershipId WHERE ms.listId=zn.from_membershipListingId;

COMMIT;

