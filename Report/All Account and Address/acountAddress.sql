####################################################################################################################################
#
#                                    All account and address report
#
####################################################################################################################################
DROP TABLE IF EXISTS z_newcreate_all_account_report_20200518;
DROP TABLE IF EXISTS z_newcreate_individual_and_organization_address_report_20200518;

####################################################################################################################################
#find all individual and organization account
####################################################################################################################################
CREATE TABLE z_newcreate_all_account_report_20200518
SELECT a.id `Account ID`,IF(a.isCompanyAccount=1,'Yes','No') IsCompanyAccount,u.userId,u.prefix Prefix,u.firstName `First Name`,u.middleName `Middle Name`,IF(u.userType=3,NULL,u.lastName) `Last Name`,u.suffix Suffix,a.houseHoldName `Household Name`,
a.houseHoldSalutation `Household Salutation`,IF(u.userType=3,u.lastName,NULL) `Company Name`,IF(u.deceased=1,'Yes','No') `Deceased`,IF(a.noSolicitation=1,'Yes','No') `Do Not Contact`
FROM account a 
JOIN user u ON a.id=u.accountId 
WHERE u.primaryContact=1 AND u.userType IN(1,3);

####################################################################################################################################
#exsit the basic address information
####################################################################################################################################
CREATE TABLE z_newcreate_exist_address_20200518
SELECT * FROM address WHERE userId IS NOT NULL AND (LENGTH(TRIM(street1))>0 OR LENGTH(TRIM(street2))>0 OR LENGTH(TRIM(street3))>0 OR LENGTH(TRIM(street4))>0 OR LENGTH(TRIM(city))>0 OR LENGTH(TRIM(state))>0 OR LENGTH(TRIM(province))>0 OR LENGTH(TRIM(zip))>0 OR LENGTH(TRIM(zipSuffix))>0 OR LENGTH(TRIM(county))>0 OR LENGTH(TRIM(countryId))>0);

####################################################################################################################################
#deal with individual account's company name
####################################################################################################################################
UPDATE z_newcreate_all_account_report_20200518 zn,company_contact cc SET zn.`Company Name`=cc.companyName WHERE zn.isCompanyAccount='No' AND zn.userId=cc.contactId AND LENGTH(TRIM(cc.contactId))>0 AND cc.currentEmployer=1 AND (cc.companyId IS NULL OR LENGTH(TRIM(cc.companyId))=0) AND zn.`Company Name` IS NULL AND LENGTH(TRIM(cc.companyName))>0;
UPDATE z_newcreate_all_account_report_20200518 zn,company_contact cc,company c SET zn.`Company Name`=c.`name` WHERE zn.isCompanyAccount='No' AND zn.userId=cc.contactId AND cc.companyId=c.companyId AND LENGTH(TRIM(cc.contactId))>0 AND cc.currentEmployer=1 AND LENGTH(TRIM(cc.companyId))>0 AND zn.`Company Name` IS NULL;

ALTER TABLE z_newcreate_exist_address_20200518 ADD INDEX(userId);
ALTER TABLE z_newcreate_all_account_report_20200518 ADD INDEX(userId);

####################################################################################################################################
#find all individual address
####################################################################################################################################
CREATE TABLE z_newcreate_individual_address_report_20200518
SELECT zn.`Account ID`,zn.IsCompanyAccount,zn.Prefix,zn.`First Name`,zn.`Middle Name`,zn.`Last Name`,zn.Suffix,zn.`Household Name`,zn.`Household Salutation`,zn.`Company Name`,zn.`Deceased`,zn.`Do Not Contact`,
a.id `Address ID`,IF(a.id IS NOT NULL,IF(a.primaryAddress=1,'Yes','No'),NULL) IsPrirmaryAddress,IF(a.id IS NOT NULL,IF(a.isBillingAddress=1,'Yes','No'),NULL) IsBillingAddress,IF(a.id IS NOT NULL,IF(a.isShippingAddress=1,'Yes','No'),NULL) IsShippingAddress,IF(a.id IS NOT NULL,IF(a.updateAdd=1,'Yes','No'),NULL) IsSeasonalAddress,IF(a.id IS NOT NULL,IF(a.invalid=1,'Yes','No'),NULL) IsValidAddress,
a.startDate `Seasonal Address Start Date`,a.endDate `Seasonal Address End Date`,t.description `Address Type`,a.street1 `Address Line 1`,a.street2 `Address Line 2`,a.street3 `Address Line 3`,a.street4 `Address Line 4`,a.city City,a.state State,a.province Province,a.county County,CONCAT_WS('-',a.zip,IF(LENGTH(TRIM(a.zipSuffix))=0,NULL,a.zipSuffix)) `Zip Code`,c.`name` Country 
FROM z_newcreate_all_account_report_20200518 zn 
LEFT JOIN z_newcreate_exist_address_20200518 a ON zn.userId=a.userId
LEFT JOIN address_type t ON a.addressType=t.id
LEFT JOIN country c ON a.countryId=c.id 
WHERE zn.isCompanyAccount='No';

####################################################################################################################################
#find all organization address
####################################################################################################################################
CREATE TABLE z_newcreate_organization_address_report_20200518
SELECT zn.`Account ID`,zn.IsCompanyAccount,u.prefix Prefix,u.firstName `First Name`,u.middleName `Middle Name`,u.lastName `Last Name`,u.suffix Suffix,zn.`Household Name`,zn.`Household Salutation`,zn.`Company Name`,IF(u.deceased=1,'Yes','No') `Deceased`,zn.`Do Not Contact`,
a.id `Address ID`,IF(a.id IS NOT NULL,IF(a.primaryAddress=1,'Yes','No'),NULL) IsPrirmaryAddress,IF(a.id IS NOT NULL,IF(a.isBillingAddress=1,'Yes','No'),NULL) IsBillingAddress,IF(a.id IS NOT NULL,IF(a.isShippingAddress=1,'Yes','No'),NULL) IsShippingAddress,IF(a.id IS NOT NULL,IF(a.updateAdd=1,'Yes','No'),NULL) IsSeasonalAddress,IF(a.id IS NOT NULL,IF(a.invalid=1,'Yes','No'),NULL) IsValidAddress,
a.startDate `Seasonal Address Start Date`,a.endDate `Seasonal Address End Date`,t.description `Address Type`,a.street1 `Address Line 1`,a.street2 `Address Line 2`,a.street3 `Address Line 3`,a.street4 `Address Line 4`,a.city City,a.state State,a.province Province,a.county County,CONCAT_WS('-',a.zip,IF(LENGTH(TRIM(a.zipSuffix))=0,NULL,a.zipSuffix)) `Zip Code`,c.`name` Country 
FROM z_newcreate_all_account_report_20200518 zn 
LEFT JOIN company_contact cc ON zn.userId=cc.companyId AND LENGTH(TRIM(cc.companyId))>0 AND (LENGTH(TRIM(cc.addressId))>0 OR LENGTH(TRIM(cc.contactId))>0)
LEFT JOIN user u ON cc.contactId=u.userId
LEFT JOIN z_newcreate_exist_address_20200518 a ON cc.addressId=a.id
LEFT JOIN address_type t ON a.addressType=t.id
LEFT JOIN country c ON a.countryId=c.id
WHERE zn.isCompanyAccount='Yes';

####################################################################################################################################
#individual and organization account report
####################################################################################################################################
CREATE TABLE z_newcreate_individual_and_organization_report_20200518
SELECT * FROM z_newcreate_individual_address_report_20200518 
UNION
SELECT * FROM z_newcreate_organization_address_report_20200518;

####################################################################################################################################
#ORDER BY 
####################################################################################################################################
CREATE TABLE z_newcreate_individual_and_organization_address_report_20200518
SELECT * FROM z_newcreate_individual_and_organization_report_20200518 ORDER BY `Account ID`+0;

DROP TABLE z_newcreate_exist_address_20200518;
DROP TABLE z_newcreate_individual_address_report_20200518;
DROP TABLE z_newcreate_organization_address_report_20200518;
DROP TABLE z_newcreate_individual_and_organization_report_20200518;

COMMIT;

