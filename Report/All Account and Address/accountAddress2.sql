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
#                 Add jobtitle salutation preferedName phone1 phone2 phone3 dobDD dobMM dobYYYY accountType
#
#
####################################################################################################################################
DROP TABLE IF EXISTS z_newcreate_all_account_report_20200710;
DROP TABLE IF EXISTS z_newcreate_update_accountType_20200710;
DROP TABLE IF EXISTS z_newcreate_individual_and_organization_address_report_20200710;

####################################################################################################################################
#account Type
####################################################################################################################################
CREATE TABLE z_newcreate_update_accountType_20200710
SELECT ui.userId,GROUP_CONCAT(DISTINCT it.name SEPARATOR ' | ') accountType FROM user_individual_type ui JOIN individual_type it ON ui.individualTypeId=it.id GROUP BY ui.userId
UNION
SELECT ui.companyId,GROUP_CONCAT(DISTINCT it.name SEPARATOR ' | ') FROM company_org_type_xref ui JOIN company_type it ON ui.companyTypeId=it.id GROUP BY ui.companyId;

####################################################################################################################################
#find all individual and organization account, and no full account for household contact
####################################################################################################################################
CREATE TABLE z_newcreate_all_account_report_20200710
SELECT a.id `Account ID`,NULL householdHeadAccountID,IF(a.isCompanyAccount=1,'Yes','No') IsCompanyAccount,u.userId,u.prefix Prefix,u.firstName `First Name`,u.middleName `Middle Name`,IF(u.userType=3,NULL,u.lastName) `Last Name`,u.suffix Suffix,u.preferredName 'Preferred Name',u.salutation 'Salutation',u.dobMM 'DOB Month',u.dobDD 'DOB Day',u.dobYYYY 'DOB Year',zn.accountType 'Individual/Company Type',a.houseHoldName `Household Name`,a.houseHoldSalutation `Household Salutation`,IF(u.userType=3,u.lastName,NULL) `Company Name`,IF(u.deceased=1,'Yes','No') `Deceased`,IF(a.noSolicitation=1,'Yes','No') `Do Not Contact`,REPLACE(u.email1,'.z2','') email1,REPLACE(u.email2,'.z2','') email2,REPLACE(u.email3,'.z2','') email3
FROM account a
JOIN user u ON a.id=u.accountId
LEFT JOIN z_newcreate_update_accountType_20200710 zn ON u.userId=zn.userId
WHERE u.primaryContact=1 AND u.userType IN(1,3)
UNION
SELECT NULL,u.accountId householdHeadAccountID,'No',u.userId,u.prefix,u.firstName,u.middleName,u.lastName,u.suffix,u.preferredName 'Preferred Name',u.salutation 'Salutation',u.dobMM 'DOB Month',u.dobDD 'DOB Day',u.dobYYYY 'DOB Year',NULL,h.name,h.houseHoldSalutation,NULL,IF(u.deceased=1,'Yes','No') `Deceased`,NULL,REPLACE(u.email1,'.z2','') email1,REPLACE(u.email2,'.z2','') email2,REPLACE(u.email3,'.z2','') email3 FROM user u
JOIN household_contact hc ON u.userId=hc.userId
JOIN household h ON hc.householdId=h.id
WHERE u.userId=hc.userId AND u.primaryContact=0;

ALTER TABLE z_newcreate_all_account_report_20200710 ADD COLUMN householdId INT DEFAULT NULL,ADD COLUMN jobTitle VARCHAR(255) DEFAULT NULL;
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

UPDATE z_newcreate_exist_address_20200710 SET phone1Type='Home' WHERE phone1Type='H';
UPDATE z_newcreate_exist_address_20200710 SET phone1Type='Work' WHERE phone1Type='W';
UPDATE z_newcreate_exist_address_20200710 SET phone1Type='Mobile' WHERE phone1Type='M';
UPDATE z_newcreate_exist_address_20200710 SET phone1Type='Other' WHERE phone1Type='O';
UPDATE z_newcreate_exist_address_20200710 SET phone2Type='Home' WHERE phone2Type='H';
UPDATE z_newcreate_exist_address_20200710 SET phone2Type='Work' WHERE phone2Type='W';
UPDATE z_newcreate_exist_address_20200710 SET phone2Type='Mobile' WHERE phone2Type='M';
UPDATE z_newcreate_exist_address_20200710 SET phone2Type='Other' WHERE phone2Type='O';
UPDATE z_newcreate_exist_address_20200710 SET phone3Type='Home' WHERE phone3Type='H';
UPDATE z_newcreate_exist_address_20200710 SET phone3Type='Work' WHERE phone3Type='W';
UPDATE z_newcreate_exist_address_20200710 SET phone3Type='Mobile' WHERE phone3Type='M';
UPDATE z_newcreate_exist_address_20200710 SET phone3Type='Other' WHERE phone3Type='O';
UPDATE z_newcreate_exist_address_20200710 SET faxType='Home' WHERE faxType='H';
UPDATE z_newcreate_exist_address_20200710 SET faxType='Work' WHERE faxType='W';
UPDATE z_newcreate_exist_address_20200710 SET faxType='Mobile' WHERE faxType='M';
UPDATE z_newcreate_exist_address_20200710 SET faxType='Other' WHERE faxType='O';

UPDATE z_newcreate_exist_address_20200710 SET phone1Number=CONCAT_WS(' ',CONCAT_WS('-',IF(LENGTH(TRIM(phone1Area))=0,NULL,phone1Area),IF(LENGTH(TRIM(phone1Number))=0,NULL,phone1Number)),phone1Type) WHERE LENGTH(TRIM(phone1Number))>0 OR LENGTH(TRIM(phone1Area))>0;
UPDATE z_newcreate_exist_address_20200710 SET phone2Number=CONCAT_WS(' ',CONCAT_WS('-',IF(LENGTH(TRIM(phone2Area))=0,NULL,phone2Area),IF(LENGTH(TRIM(phone2Number))=0,NULL,phone2Number)),phone2Type) WHERE LENGTH(TRIM(phone2Number))>0 OR LENGTH(TRIM(phone2Area))>0;
UPDATE z_newcreate_exist_address_20200710 SET phone3Number=CONCAT_WS(' ',CONCAT_WS('-',IF(LENGTH(TRIM(phone3Area))=0,NULL,phone3Area),IF(LENGTH(TRIM(phone3Number))=0,NULL,phone3Number)),phone3Type) WHERE LENGTH(TRIM(phone3Number))>0 OR LENGTH(TRIM(phone3Area))>0;
UPDATE z_newcreate_exist_address_20200710 SET phone3Number=CONCAT_WS(' ',CONCAT_WS('-',IF(LENGTH(TRIM(faxArea))=0,NULL,faxArea),IF(LENGTH(TRIM(faxNumber))=0,NULL,faxNumber)),faxType) WHERE LENGTH(TRIM(faxNumber))>0 OR LENGTH(TRIM(faxArea))>0;

####################################################################################################################################
#deal with individual account company name
####################################################################################################################################
UPDATE z_newcreate_all_account_report_20200710 zn,company_contact cc SET zn.`Company Name`=cc.companyName,zn.jobTitle=cc.title WHERE zn.isCompanyAccount='No' AND zn.userId=cc.contactId AND LENGTH(TRIM(cc.contactId))>0 AND cc.currentEmployer=1 AND (cc.companyId IS NULL OR LENGTH(TRIM(cc.companyId))=0) AND zn.`Company Name` IS NULL AND LENGTH(TRIM(cc.companyName))>0;
UPDATE z_newcreate_all_account_report_20200710 zn,company_contact cc,company c SET zn.`Company Name`=c.`name`,zn.jobTitle=cc.title WHERE zn.isCompanyAccount='No' AND zn.userId=cc.contactId AND cc.companyId=c.companyId AND LENGTH(TRIM(cc.contactId))>0 AND cc.currentEmployer=1 AND LENGTH(TRIM(cc.companyId))>0 AND zn.`Company Name` IS NULL;

ALTER TABLE z_newcreate_exist_address_20200710 ADD INDEX(userId);
ALTER TABLE z_newcreate_all_account_report_20200710 ADD INDEX(userId);

####################################################################################################################################
#find all individual address
####################################################################################################################################
CREATE TABLE z_newcreate_individual_address_report_20200710
SELECT zn.`Account ID`,zn.householdHeadAccountID,zn.householdId `Household ID`,zn.IsCompanyAccount,zn.Prefix,zn.`First Name`,zn.`Middle Name`,zn.`Last Name`,zn.Suffix,zn.`Preferred Name`,zn.`Salutation`,zn.`DOB Month`,zn.`DOB Day`,zn.`DOB Year`,zn.`Individual/Company Type`,zn.jobTitle,zn.`Household Name`,zn.`Household Salutation`,zn.`Company Name`,zn.`Deceased`,zn.`Do Not Contact`,zn.email1,zn.email2,zn.email3,a.id `Address ID`,IF(a.id IS NOT NULL,IF(a.primaryAddress=1,'Yes','No'),NULL) IsPrirmaryAddress,IF(a.id IS NOT NULL,IF(a.isBillingAddress=1,'Yes','No'),NULL) IsBillingAddress,IF(a.id IS NOT NULL,IF(a.isShippingAddress=1,'Yes','No'),NULL) IsShippingAddress,IF(a.id IS NOT NULL,IF(a.updateAdd=1,'Yes','No'),NULL) IsSeasonalAddress,IF(a.id IS NOT NULL,IF(a.invalid=1,'No','Yes'),NULL) IsValidAddress,
a.startDate `Seasonal Address Start Date`,a.endDate `Seasonal Address End Date`,t.description `Address Type`,a.street1 `Address Line 1`,a.street2 `Address Line 2`,a.street3 `Address Line 3`,a.street4 `Address Line 4`,a.city City,a.state State,a.province Province,a.county County,CONCAT_WS('-',a.zip,IF(LENGTH(TRIM(a.zipSuffix))=0,NULL,a.zipSuffix)) `Zip Code`,c.`name` Country,a.phone1Number `Phone 1`,a.phone2Number `Phone 2`,a.phone3Number `Phone 3`,a.faxNumber Fax
FROM z_newcreate_all_account_report_20200710 zn
LEFT JOIN z_newcreate_exist_address_20200710 a ON zn.userId=a.userId
LEFT JOIN address_type t ON a.addressType=t.id
LEFT JOIN country c ON a.countryId=c.id
WHERE zn.isCompanyAccount='No';

####################################################################################################################################
#find all organization address and company contact
####################################################################################################################################
CREATE TABLE z_newcreate_organization_address_report_20200710
SELECT zn.`Account ID`,zn.householdHeadAccountID,zn.householdId `Household ID`,zn.IsCompanyAccount,u.prefix Prefix,u.firstName `First Name`,u.middleName `Middle Name`,u.lastName `Last Name`,u.suffix Suffix,u.preferredName,u.salutation,zn.`DOB Month`,zn.`DOB Day`,zn.`DOB Year`,zn.`Individual/Company Type`,cc.title,zn.`Household Name`,zn.`Household Salutation`,zn.`Company Name`,IF(u.deceased=1,'Yes','No') `Deceased`,zn.`Do Not Contact`,REPLACE(cc.email,'.z2','') email1,zn.email2,zn.email3,
a.id `Address ID`,IF(a.id IS NOT NULL,IF(a.primaryAddress=1,'Yes','No'),NULL) IsPrirmaryAddress,IF(a.id IS NOT NULL,IF(a.isBillingAddress=1,'Yes','No'),NULL) IsBillingAddress,IF(a.id IS NOT NULL,IF(a.isShippingAddress=1,'Yes','No'),NULL) IsShippingAddress,IF(a.id IS NOT NULL,IF(a.updateAdd=1,'Yes','No'),NULL) IsSeasonalAddress,IF(a.id IS NOT NULL,IF(a.invalid=1,'No','Yes'),NULL) IsValidAddress,
a.startDate `Seasonal Address Start Date`,a.endDate `Seasonal Address End Date`,t.description `Address Type`,a.street1 `Address Line 1`,a.street2 `Address Line 2`,a.street3 `Address Line 3`,a.street4 `Address Line 4`,a.city City,a.state State,a.province Province,a.county County,CONCAT_WS('-',a.zip,IF(LENGTH(TRIM(a.zipSuffix))=0,NULL,a.zipSuffix)) `Zip Code`,c.`name` Country,a.phone1Number `Phone 1`,a.phone2Number `Phone 2`,a.phone3Number `Phone 3`,a.faxNumber Fax
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
