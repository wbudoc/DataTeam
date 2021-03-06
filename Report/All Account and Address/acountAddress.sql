####################################################################################################################################
#                                                    INT-15
#
#                 All account and address report
#
#                                                    CC-3325
#
#                 Add new column householdHeadAccount, `Household ID`, email1, email2, email3
#                 Catch data no full account for household and company contact
#
#
#
####################################################################################################################################
DROP TABLE IF EXISTS z_newcreate_all_account_report_20200710;
DROP TABLE IF EXISTS z_newcreate_individual_and_organization_address_report_20200710;

####################################################################################################################################
#find all individual and organization account, and no full account for household contact
####################################################################################################################################
CREATE TABLE z_newcreate_all_account_report_20200710
SELECT a.id `Account ID`,NULL householdHeadAccountID,IF(a.isCompanyAccount=1,'Yes','No') IsCompanyAccount,u.userId,u.prefix Prefix,u.firstName `First Name`,u.middleName `Middle Name`,IF(u.userType=3,NULL,u.lastName) `Last Name`,u.suffix Suffix,a.houseHoldName `Household Name`,
a.houseHoldSalutation `Household Salutation`,IF(u.userType=3,u.lastName,NULL) `Company Name`,IF(u.deceased=1,'Yes','No') `Deceased`,IF(a.noSolicitation=1,'Yes','No') `Do Not Contact`,REPLACE(u.email1,'.z2','') email1,REPLACE(u.email2,'.z2','') email2,REPLACE(u.email3,'.z2','') email3
FROM account a
JOIN user u ON a.id=u.accountId
WHERE u.primaryContact=1 AND u.userType IN(1,3)
UNION
SELECT NULL,u.accountId householdHeadAccountID,'No',u.userId,u.prefix,u.firstName,u.middleName,u.lastName,u.suffix,h.name,h.houseHoldSalutation,NULL,IF(u.deceased=1,'Yes','No') `Deceased`,NULL,REPLACE(u.email1,'.z2','') email1,REPLACE(u.email2,'.z2','') email2,REPLACE(u.email3,'.z2','') email3 FROM user u
JOIN household_contact hc ON u.userId=hc.userId
JOIN household h ON hc.householdId=h.id
WHERE u.userId=hc.userId AND u.primaryContact=0;

ALTER TABLE z_newcreate_all_account_report_20200710 ADD COLUMN householdId INT DEFAULT NULL;
UPDATE z_newcreate_all_account_report_20200710 zn,household_contact hc SET zn.householdId=hc.householdId WHERE zn.userId=hc.userId AND hc.isPrimaryHousehold=1;
UPDATE z_newcreate_all_account_report_20200710 zn,household_contact hc SET zn.householdId=hc.householdId WHERE zn.householdHeadAccountID IS NOT NULL AND zn.userId=hc.userId AND hc.isPrimaryHousehold IS NULL;

####################################################################################################################################
#exsit the basic address information
####################################################################################################################################
CREATE TABLE z_newcreate_exist_address_20200710
SELECT * FROM address WHERE userId IS NOT NULL AND (LENGTH(TRIM(street1))>0 OR LENGTH(TRIM(street2))>0 OR LENGTH(TRIM(street3))>0 OR LENGTH(TRIM(street4))>0 OR LENGTH(TRIM(city))>0 OR LENGTH(TRIM(state))>0 OR LENGTH(TRIM(province))>0 OR LENGTH(TRIM(zip))>0 OR LENGTH(TRIM(zipSuffix))>0 OR LENGTH(TRIM(county))>0 OR LENGTH(TRIM(countryId))>0);

UPDATE z_newcreate_exist_address_20200710 zn,state s SET zn.state=s.name WHERE zn.state=s.abbreviation AND zn.state IS NOT NULL;

ALTER TABLE z_newcreate_exist_address_20200710 MODIFY COLUMN startDate VARCHAR(100),MODIFY COLUMN endDate VARCHAR(100);

UPDATE z_newcreate_exist_address_20200710 SET startDate=REPLACE(SUBSTRING_INDEX(startDate,'-',-2),'-','/') WHERE updateAdd=1 AND startDate LIKE '1000-%';
UPDATE z_newcreate_exist_address_20200710 SET endDate=REPLACE(SUBSTRING_INDEX(endDate,'-',-2),'-','/') WHERE updateAdd=1 AND endDate LIKE '1000-%';

####################################################################################################################################
#deal with individual account company name
####################################################################################################################################
UPDATE z_newcreate_all_account_report_20200710 zn,company_contact cc SET zn.`Company Name`=cc.companyName WHERE zn.isCompanyAccount='No' AND zn.userId=cc.contactId AND LENGTH(TRIM(cc.contactId))>0 AND cc.currentEmployer=1 AND (cc.companyId IS NULL OR LENGTH(TRIM(cc.companyId))=0) AND zn.`Company Name` IS NULL AND LENGTH(TRIM(cc.companyName))>0;
UPDATE z_newcreate_all_account_report_20200710 zn,company_contact cc,company c SET zn.`Company Name`=c.`name` WHERE zn.isCompanyAccount='No' AND zn.userId=cc.contactId AND cc.companyId=c.companyId AND LENGTH(TRIM(cc.contactId))>0 AND cc.currentEmployer=1 AND LENGTH(TRIM(cc.companyId))>0 AND zn.`Company Name` IS NULL;

ALTER TABLE z_newcreate_exist_address_20200710 ADD INDEX(userId);
ALTER TABLE z_newcreate_all_account_report_20200710 ADD INDEX(userId);

####################################################################################################################################
#find all individual address
####################################################################################################################################
CREATE TABLE z_newcreate_individual_address_report_20200710
SELECT zn.`Account ID`,zn.householdHeadAccountID,zn.householdId `Household ID`,zn.IsCompanyAccount,zn.Prefix,zn.`First Name`,zn.`Middle Name`,zn.`Last Name`,zn.Suffix,zn.`Household Name`,zn.`Household Salutation`,zn.`Company Name`,zn.`Deceased`,zn.`Do Not Contact`,zn.email1,zn.email2,zn.email3,
a.id `Address ID`,IF(a.id IS NOT NULL,IF(a.primaryAddress=1,'Yes','No'),NULL) IsPrirmaryAddress,IF(a.id IS NOT NULL,IF(a.isBillingAddress=1,'Yes','No'),NULL) IsBillingAddress,IF(a.id IS NOT NULL,IF(a.isShippingAddress=1,'Yes','No'),NULL) IsShippingAddress,IF(a.id IS NOT NULL,IF(a.updateAdd=1,'Yes','No'),NULL) IsSeasonalAddress,IF(a.id IS NOT NULL,IF(a.invalid=1,'No','Yes'),NULL) IsValidAddress,
a.startDate `Seasonal Address Start Date`,a.endDate `Seasonal Address End Date`,t.description `Address Type`,a.street1 `Address Line 1`,a.street2 `Address Line 2`,a.street3 `Address Line 3`,a.street4 `Address Line 4`,a.city City,a.state State,a.province Province,a.county County,CONCAT_WS('-',a.zip,IF(LENGTH(TRIM(a.zipSuffix))=0,NULL,a.zipSuffix)) `Zip Code`,c.`name` Country
FROM z_newcreate_all_account_report_20200710 zn
LEFT JOIN z_newcreate_exist_address_20200710 a ON zn.userId=a.userId
LEFT JOIN address_type t ON a.addressType=t.id
LEFT JOIN country c ON a.countryId=c.id
WHERE zn.isCompanyAccount='No';

####################################################################################################################################
#find all organization address and company contact
####################################################################################################################################
CREATE TABLE z_newcreate_organization_address_report_20200710
SELECT zn.`Account ID`,zn.householdHeadAccountID,zn.householdId `Household ID`,zn.IsCompanyAccount,u.prefix Prefix,u.firstName `First Name`,u.middleName `Middle Name`,u.lastName `Last Name`,u.suffix Suffix,zn.`Household Name`,zn.`Household Salutation`,zn.`Company Name`,IF(u.deceased=1,'Yes','No') `Deceased`,zn.`Do Not Contact`,REPLACE(cc.email,'.z2','') email1,zn.email2,zn.email3,
a.id `Address ID`,IF(a.id IS NOT NULL,IF(a.primaryAddress=1,'Yes','No'),NULL) IsPrirmaryAddress,IF(a.id IS NOT NULL,IF(a.isBillingAddress=1,'Yes','No'),NULL) IsBillingAddress,IF(a.id IS NOT NULL,IF(a.isShippingAddress=1,'Yes','No'),NULL) IsShippingAddress,IF(a.id IS NOT NULL,IF(a.updateAdd=1,'Yes','No'),NULL) IsSeasonalAddress,IF(a.id IS NOT NULL,IF(a.invalid=1,'No','Yes'),NULL) IsValidAddress,
a.startDate `Seasonal Address Start Date`,a.endDate `Seasonal Address End Date`,t.description `Address Type`,a.street1 `Address Line 1`,a.street2 `Address Line 2`,a.street3 `Address Line 3`,a.street4 `Address Line 4`,a.city City,a.state State,a.province Province,a.county County,CONCAT_WS('-',a.zip,IF(LENGTH(TRIM(a.zipSuffix))=0,NULL,a.zipSuffix)) `Zip Code`,c.`name` Country
FROM z_newcreate_all_account_report_20200710 zn
LEFT JOIN company_contact cc ON zn.userId=cc.companyId AND LENGTH(TRIM(cc.companyId))>0 AND (LENGTH(TRIM(cc.addressId))>0 OR LENGTH(TRIM(cc.contactId))>0)
LEFT JOIN user u ON cc.contactId=u.userId
LEFT JOIN z_newcreate_exist_address_20200710 a ON cc.addressId=a.id
LEFT JOIN address_type t ON a.addressType=t.id
LEFT JOIN country c ON a.countryId=c.id
WHERE zn.isCompanyAccount='Yes';

####################################################################################################################################
#individual and organization account report
####################################################################################################################################
CREATE TABLE z_newcreate_individual_and_organization_report_20200710
SELECT * FROM z_newcreate_individual_address_report_20200710
UNION
SELECT * FROM z_newcreate_organization_address_report_20200710;

####################################################################################################################################
#ORDER BY
####################################################################################################################################
CREATE TABLE z_newcreate_individual_and_organization_address_report_20200710
SELECT * FROM z_newcreate_individual_and_organization_report_20200710 ORDER BY IF(`Account ID`+0 IS NULL,householdHeadAccountID+0,`Account ID`+0);

DROP TABLE z_newcreate_exist_address_20200710;
DROP TABLE z_newcreate_individual_address_report_20200710;
DROP TABLE z_newcreate_organization_address_report_20200710;
DROP TABLE z_newcreate_individual_and_organization_report_20200710;

COMMIT;
