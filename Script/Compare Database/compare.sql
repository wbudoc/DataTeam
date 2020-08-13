##########################################################################################################################################################
#
#                                                       Compare Databse
#
#                                                SET @to_databaseName= 对比的数据库名字
#
##########################################################################################################################################################

SET @to_databaseName='blank_bak';
SET @old_group_concat_max_len=@@group_concat_max_len,group_concat_max_len=2000000;
DROP TABLE IF EXISTS z_newcreate_prepare_statement_to_proceed;
DROP TABLE IF EXISTS z_newcreate_is_key_all_table;
DROP TABLE IF EXISTS z_newcreate_no_key_all_table;
DROP TABLE IF EXISTS z_newcreate_table_isExist_key;
DROP TABLE IF EXISTS z_newcreate_table_isExist2_key;
DROP TABLE IF EXISTS z_newcreate_update_or_add;
DROP TABLE IF EXISTS z_newcreate_update_or_add_final;
DROP TABLE IF EXISTS z_newcreate_all_option_infor;

CREATE TABLE z_newcreate_prepare_statement_to_proceed(id int primary key auto_increment, sql_stmt TEXT);
CREATE TABLE z_newcreate_is_key_all_table(tableName VARCHAR(255), all_infor TEXT,comefrom INT,instance VARCHAR(255));
CREATE TABLE z_newcreate_no_key_all_table(tableName VARCHAR(255), all_infor TEXT,comefrom INT,instance VARCHAR(255));
CREATE TABLE z_newcreate_all_option_infor(tableName VARCHAR(255), key_value_data VARCHAR(255),update_infor TEXT,option_method VARCHAR(255),column_default_value VARCHAR(255));

DELIMITER //

DROP PROCEDURE IF EXISTS dt_wl_proceed_prepare_statement //
CREATE PROCEDURE dt_wl_proceed_prepare_statement() LANGUAGE SQL MODIFIES SQL DATA  SQL SECURITY  DEFINER
BEGIN

DECLARE prepare_stmt TEXT;
DECLARE stopFlag TINYINT DEFAULT 0;

DECLARE all_prepare_stmt_cursor CURSOR FOR
		SELECT sql_stmt FROM z_newcreate_prepare_statement_to_proceed order by id asc;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET stopFlag=1;

OPEN all_prepare_stmt_cursor;
	REPEAT
			FETCH  all_prepare_stmt_cursor INTO prepare_stmt;
SET @stmt=prepare_stmt;

IF stopFlag=0 THEN
	PREPARE pstmt_wl FROM @stmt;
	EXECUTE pstmt_wl;
END IF;
	UNTIL stopFlag END REPEAT;

DELETE FROM z_newcreate_prepare_statement_to_proceed;

END//

DELIMITER ;

INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('DROP TABLE ',TABLE_NAME,';') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_key_20200205';

CALL dt_wl_proceed_prepare_statement();

###############################################################################################################################
#display current database where all table isExist primary key
###############################################################################################################################
#557
CREATE TABLE z_newcreate_table_isExist_key
SELECT TABLE_SCHEMA,TABLE_NAME,COUNT(*) pri_Key_Number,GROUP_CONCAT(DISTINCT CONCAT('`',COLUMN_NAME,'`') ORDER BY ORDINAL_POSITION SEPARATOR ', ') pri_Key_Column,GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', ') pri_Key_Column1 FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN(SELECT TABLE_NAME FROM information_schema.`TABLES` zn2 WHERE zn2.TABLE_SCHEMA=DATABASE() AND zn2.TABLE_NAME NOT LIKE 'z_newcreate%' AND zn2.TABLE_NAME NOT LIKE 'z_excel%' AND zn2.TABLE_NAME NOT LIKE 'final_merge_%' AND zn2.TABLE_NAME NOT LIKE 'z_check_cut_off_before%' AND zn2.TABLE_NAME NOT LIKE 'smoke_test_report%' AND zn2.TABLE_TYPE<>'VIEW' AND zn2.TABLE_NAME NOT LIKE 'all_extra_%' AND zn2.TABLE_NAME NOT LIKE 'deal_with_extra%') AND COLUMN_KEY='PRI' GROUP BY TABLE_NAME;
 
#48
INSERT INTO z_newcreate_table_isExist_key
SELECT TABLE_SCHEMA,TABLE_NAME,0,GROUP_CONCAT(DISTINCT CONCAT('`',COLUMN_NAME,'`') ORDER BY ORDINAL_POSITION SEPARATOR ', ') pri_Key_Column,GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', ') pri_Key_Column1 FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN(SELECT TABLE_NAME FROM information_schema.`TABLES` zn2 WHERE zn2.TABLE_SCHEMA=DATABASE() AND zn2.TABLE_NAME NOT LIKE 'z_newcreate%' AND zn2.TABLE_NAME NOT LIKE 'z_excel%' AND zn2.TABLE_NAME NOT LIKE 'final_merge_%' AND zn2.TABLE_NAME NOT LIKE 'z_check_cut_off_before%' AND zn2.TABLE_NAME NOT LIKE 'smoke_test_report%' AND zn2.TABLE_TYPE<>'VIEW' AND zn2.TABLE_NAME NOT LIKE 'all_extra_%' AND zn2.TABLE_NAME NOT LIKE 'deal_with_extra%') AND TABLE_NAME NOT IN(SELECT TABLE_NAME FROM z_newcreate_table_isExist_key) GROUP BY TABLE_NAME;

###############################################################################################################################
#display compare database where all table isExist primary key
###############################################################################################################################
#557
CREATE TABLE z_newcreate_table_isExist2_key
SELECT TABLE_SCHEMA,TABLE_NAME,COUNT(*) pri_Key_Number,GROUP_CONCAT(DISTINCT CONCAT('`',COLUMN_NAME,'`') ORDER BY ORDINAL_POSITION SEPARATOR ', ') pri_Key_Column,GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', ') pri_Key_Column1 FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=@to_databaseName AND TABLE_NAME IN(SELECT TABLE_NAME FROM information_schema.`TABLES` zn2 WHERE zn2.TABLE_SCHEMA=@to_databaseName AND zn2.TABLE_NAME NOT LIKE 'z_newcreate%' AND zn2.TABLE_NAME NOT LIKE 'z_excel%' AND zn2.TABLE_NAME NOT LIKE 'final_merge_%' AND zn2.TABLE_NAME NOT LIKE 'z_check_cut_off_before%' AND zn2.TABLE_NAME NOT LIKE 'smoke_test_report%' AND zn2.TABLE_TYPE<>'VIEW' AND zn2.TABLE_NAME NOT LIKE 'all_extra_%' AND zn2.TABLE_NAME NOT LIKE 'deal_with_extra%') AND COLUMN_KEY='PRI' GROUP BY TABLE_NAME;
 
#48
INSERT INTO z_newcreate_table_isExist2_key
SELECT TABLE_SCHEMA,TABLE_NAME,0,GROUP_CONCAT(DISTINCT CONCAT('`',COLUMN_NAME,'`') ORDER BY ORDINAL_POSITION SEPARATOR ', ') pri_Key_Column,GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', ') pri_Key_Column1 FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=@to_databaseName AND TABLE_NAME IN(SELECT TABLE_NAME FROM information_schema.`TABLES` zn2 WHERE zn2.TABLE_SCHEMA=@to_databaseName AND zn2.TABLE_NAME NOT LIKE 'z_newcreate%' AND zn2.TABLE_NAME NOT LIKE 'z_excel%' AND zn2.TABLE_NAME NOT LIKE 'final_merge_%' AND zn2.TABLE_NAME NOT LIKE 'z_check_cut_off_before%' AND zn2.TABLE_NAME NOT LIKE 'smoke_test_report%' AND zn2.TABLE_TYPE<>'VIEW' AND zn2.TABLE_NAME NOT LIKE 'all_extra_%' AND zn2.TABLE_NAME NOT LIKE 'deal_with_extra%') AND TABLE_NAME NOT IN(SELECT TABLE_NAME FROM z_newcreate_table_isExist2_key) GROUP BY TABLE_NAME;

ALTER TABLE z_newcreate_table_isExist_key ADD INDEX(TABLE_NAME);

############################################################################################################################
#query all the data for exist the primary key table
############################################################################################################################
INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('INSERT INTO z_newcreate_is_key_all_table ',GROUP_CONCAT(DISTINCT a.con_sql SEPARATOR ' UNION ALL '),';') con_sql FROM 
(SELECT CONCAT("SELECT '",zn1.TABLE_NAME,"' tableName, MD5(CONCAT(",GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',zn1.COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', '),")) allinfor,1 comfrom,'",zn1.TABLE_SCHEMA,"' instance FROM ",zn1.TABLE_SCHEMA,'.',zn1.TABLE_NAME) con_sql,zn1.TABLE_NAME FROM information_schema.`COLUMNS` zn1 JOIN information_schema.`TABLES` zn2 ON zn1.TABLE_NAME=zn2.TABLE_NAME WHERE zn1.TABLE_SCHEMA=DATABASE() AND zn2.TABLE_SCHEMA=DATABASE() AND zn2.TABLE_NAME IN(SELECT TABLE_NAME FROM z_newcreate_table_isExist_key WHERE pri_Key_Number>0) GROUP BY zn1.TABLE_NAME
UNION
SELECT CONCAT("SELECT '",zn1.TABLE_NAME,"' tableName, MD5(CONCAT(",GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',zn1.COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', '),")) allinfor,2 comfrom,'",zn1.TABLE_SCHEMA,"' instance FROM ",zn1.TABLE_SCHEMA,'.',zn1.TABLE_NAME) con_sql,zn1.TABLE_NAME FROM information_schema.`COLUMNS` zn1 JOIN information_schema.`TABLES` zn2 ON zn1.TABLE_NAME=zn2.TABLE_NAME WHERE zn1.TABLE_SCHEMA=@to_databaseName AND zn2.TABLE_SCHEMA=@to_databaseName AND zn2.TABLE_NAME IN(SELECT TABLE_NAME FROM z_newcreate_table_isExist_key WHERE pri_Key_Number>0) GROUP BY zn1.TABLE_NAME) a GROUP BY a.TABLE_NAME;

############################################################################################################################
#query all the data for not exist the primary key table
############################################################################################################################
INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('INSERT INTO z_newcreate_no_key_all_table ',GROUP_CONCAT(DISTINCT a.con_sql SEPARATOR ' UNION ALL '),';') con_sql FROM 
(SELECT CONCAT("SELECT '",zn1.TABLE_NAME,"' tableName, MD5(CONCAT(",GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',zn1.COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', '),")) allinfor,1 comfrom,'",zn1.TABLE_SCHEMA,"' instance FROM ",zn1.TABLE_SCHEMA,'.',zn1.TABLE_NAME) con_sql,zn1.TABLE_NAME FROM information_schema.`COLUMNS` zn1 JOIN information_schema.`TABLES` zn2 ON zn1.TABLE_NAME=zn2.TABLE_NAME WHERE zn1.TABLE_SCHEMA=DATABASE() AND zn2.TABLE_SCHEMA=DATABASE() AND zn2.TABLE_NAME IN(SELECT TABLE_NAME FROM z_newcreate_table_isExist_key WHERE pri_Key_Number=0) GROUP BY zn1.TABLE_NAME
UNION
SELECT CONCAT("SELECT '",zn1.TABLE_NAME,"' tableName, MD5(CONCAT(",GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',zn1.COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', '),")) allinfor,2 comfrom,'",zn1.TABLE_SCHEMA,"' instance FROM ",zn1.TABLE_SCHEMA,'.',zn1.TABLE_NAME) con_sql,zn1.TABLE_NAME FROM information_schema.`COLUMNS` zn1 JOIN information_schema.`TABLES` zn2 ON zn1.TABLE_NAME=zn2.TABLE_NAME WHERE zn1.TABLE_SCHEMA=@to_databaseName AND zn2.TABLE_SCHEMA=@to_databaseName AND zn2.TABLE_NAME IN(SELECT TABLE_NAME FROM z_newcreate_table_isExist_key WHERE pri_Key_Number=0) GROUP BY zn1.TABLE_NAME) a GROUP BY a.TABLE_NAME;

CALL dt_wl_proceed_prepare_statement();
ALTER TABLE z_newcreate_no_key_all_table ADD COLUMN count INT DEFAULT NULL;
ALTER TABLE z_newcreate_is_key_all_table MODIFY COLUMN all_infor VARCHAR(255);
ALTER TABLE z_newcreate_no_key_all_table MODIFY COLUMN all_infor VARCHAR(255);
ALTER TABLE z_newcreate_is_key_all_table ADD INDEX(tableName),ADD INDEX(all_infor);
ALTER TABLE z_newcreate_no_key_all_table ADD INDEX(tableName),ADD INDEX(all_infor),ADD INDEX(count);

CREATE TABLE z_newcreate_total_number
SELECT *,COUNT(*) num FROM z_newcreate_no_key_all_table GROUP BY CONCAT_WS('#',tableName,all_infor,comefrom);

UPDATE z_newcreate_no_key_all_table zn,z_newcreate_total_number zt SET zn.count=zt.num WHERE zn.tableName=zt.tableName AND zn.all_infor=zt.all_infor AND zn.comefrom=zt.comefrom;

DROP TABLE z_newcreate_total_number;
############################################################################################################################
#Query the change table
############################################################################################################################
DELETE zn1.*,zn2.* FROM z_newcreate_is_key_all_table zn1,z_newcreate_is_key_all_table zn2 WHERE zn1.tableName=zn2.tableName AND zn1.all_infor=zn2.all_infor AND zn1.comefrom=1 AND zn2.comefrom=2;
DELETE zn1.*,zn2.* FROM z_newcreate_no_key_all_table zn1,z_newcreate_no_key_all_table zn2 WHERE zn1.tableName=zn2.tableName AND zn1.all_infor=zn2.all_infor AND zn1.count=zn2.count AND zn1.comefrom=1 AND zn2.comefrom=2;

############################################################################################################################
#Query the change table for have primary key
############################################################################################################################
INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('CREATE TABLE compare_',TABLE_NAME,'_is_key_20200205 ',GROUP_CONCAT(DISTINCT a.con_sql SEPARATOR ' UNION ALL '),';') con_sql FROM 
(SELECT CONCAT('SELECT ',GROUP_CONCAT(DISTINCT CONCAT('`',COLUMN_NAME,'`') ORDER BY ORDINAL_POSITION SEPARATOR ', '),",'",TABLE_NAME,"' comefrom_tableName,MD5(CONCAT(",GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', '),")) allinfor,'",TABLE_SCHEMA,"' instance FROM ",TABLE_SCHEMA,'.',TABLE_NAME) con_sql,TABLE_NAME FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN(SELECT tableName FROM z_newcreate_is_key_all_table) GROUP BY TABLE_NAME
UNION
SELECT CONCAT('SELECT ',GROUP_CONCAT(DISTINCT CONCAT('`',COLUMN_NAME,'`') ORDER BY ORDINAL_POSITION SEPARATOR ', '),",'",TABLE_NAME,"' comefrom_tableName,MD5(CONCAT(",GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', '),")) allinfor,'",TABLE_SCHEMA,"' instance FROM ",TABLE_SCHEMA,'.',TABLE_NAME) con_sql,TABLE_NAME FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=@to_databaseName AND TABLE_NAME IN(SELECT tableName FROM z_newcreate_is_key_all_table) GROUP BY TABLE_NAME) a GROUP BY a.TABLE_NAME;

############################################################################################################################
#Query the change table for no primary key
############################################################################################################################
INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('CREATE TABLE compare_',TABLE_NAME,'_no_key_20200205 ',GROUP_CONCAT(DISTINCT a.con_sql SEPARATOR ' UNION ALL '),';') con_sql FROM 
(SELECT CONCAT('SELECT ',GROUP_CONCAT(DISTINCT CONCAT('`',COLUMN_NAME,'`') ORDER BY ORDINAL_POSITION SEPARATOR ', '),",'",TABLE_NAME,"' comefrom_tableName,MD5(CONCAT(",GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', '),")) allinfor,'",TABLE_SCHEMA,"' instance FROM ",TABLE_SCHEMA,'.',TABLE_NAME) con_sql,TABLE_NAME FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN(SELECT tableName FROM z_newcreate_no_key_all_table) GROUP BY TABLE_NAME
UNION
SELECT CONCAT('SELECT ',GROUP_CONCAT(DISTINCT CONCAT('`',COLUMN_NAME,'`') ORDER BY ORDINAL_POSITION SEPARATOR ', '),",'",TABLE_NAME,"' comefrom_tableName,MD5(CONCAT(",GROUP_CONCAT(DISTINCT CONCAT('IFNULL(`',COLUMN_NAME,'`,'''')') ORDER BY ORDINAL_POSITION SEPARATOR ', '),")) allinfor,'",TABLE_SCHEMA,"' instance FROM ",TABLE_SCHEMA,'.',TABLE_NAME) con_sql,TABLE_NAME FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=@to_databaseName AND TABLE_NAME IN(SELECT tableName FROM z_newcreate_no_key_all_table) GROUP BY TABLE_NAME) a GROUP BY a.TABLE_NAME;

CALL dt_wl_proceed_prepare_statement();

############################################################################################################################
#dispaly the change data for every change table
############################################################################################################################
INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('ALTER TABLE ',TABLE_NAME,' ADD INDEX(comefrom_tableName),ADD INDEX(allinfor);') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_is_key_20200205'
UNION
SELECT CONCAT('ALTER TABLE ',TABLE_NAME,' ADD INDEX(comefrom_tableName),ADD INDEX(allinfor);') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_no_key_20200205'
UNION
SELECT CONCAT('CREATE TABLE ',TABLE_NAME,'_f SELECT zn.* FROM ',TABLE_NAME,' zn,z_newcreate_is_key_all_table a WHERE zn.allinfor=a.all_infor AND a.tableName=zn.comefrom_tableName;') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_is_key_20200205'
UNION
SELECT CONCAT('CREATE TABLE ',TABLE_NAME,'_f SELECT zn.* FROM ',TABLE_NAME,' zn,(SELECT DISTINCT all_infor,tableName FROM z_newcreate_no_key_all_table) a WHERE zn.allinfor=a.all_infor AND a.tableName=zn.comefrom_tableName;') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_no_key_20200205'
UNION
SELECT CONCAT('DROP TABLE ',TABLE_NAME,';') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_key_20200205'
UNION
SELECT CONCAT('CREATE TABLE compare_',TABLE_NAME,"_is_key_20200205 SELECT *,'INSERT' update_or_add,MD5(CONCAT(",pri_Key_Column1,")) key_value_data FROM compare_",TABLE_NAME,'_is_key_20200205_f ORDER BY ',pri_Key_Column,';') FROM z_newcreate_table_isExist_key WHERE pri_Key_Number>0 AND TABLE_NAME IN(SELECT DISTINCT tableName FROM z_newcreate_is_key_all_table)
UNION
SELECT CONCAT('CREATE TABLE compare_',TABLE_NAME,"_no_key_20200205 SELECT *,'INSERT' update_or_add,MD5(CONCAT(",pri_Key_Column1,")) key_value_data FROM compare_",TABLE_NAME,'_no_key_20200205_f ORDER BY ',pri_Key_Column,';') FROM z_newcreate_table_isExist_key WHERE pri_Key_Number=0 AND TABLE_NAME IN(SELECT DISTINCT tableName FROM z_newcreate_no_key_all_table);

CALL dt_wl_proceed_prepare_statement();

INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('DROP TABLE ',TABLE_NAME,';') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_key_20200205_f';

CALL dt_wl_proceed_prepare_statement();
############################################################################################################################
#mark update record
############################################################################################################################
INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('ALTER TABLE ',TABLE_NAME,' ADD INDEX(key_value_data);') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_is_key_20200205'
UNION
SELECT CONCAT('ALTER TABLE ',TABLE_NAME,' ADD INDEX(key_value_data);') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_no_key_20200205'
UNION
SELECT CONCAT('UPDATE compare_',TABLE_NAME,'_is_key_20200205 zn1,compare_',TABLE_NAME,"_is_key_20200205 zn2 SET zn1.update_or_add='UPDATE' WHERE zn1.instance<>zn2.instance AND zn1.key_value_data=zn2.key_value_data") FROM z_newcreate_table_isExist_key WHERE pri_Key_Number>0 AND TABLE_NAME IN(SELECT DISTINCT tableName FROM z_newcreate_is_key_all_table)
UNION
SELECT CONCAT('UPDATE compare_',TABLE_NAME,'_no_key_20200205 zn1,compare_',TABLE_NAME,"_no_key_20200205 zn2 SET zn1.update_or_add='UPDATE' WHERE zn1.instance<>zn2.instance AND zn1.key_value_data=zn2.key_value_data") FROM z_newcreate_table_isExist_key WHERE pri_Key_Number=0 AND TABLE_NAME IN(SELECT DISTINCT tableName FROM z_newcreate_no_key_all_table);

CALL dt_wl_proceed_prepare_statement();

INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('UPDATE ',TABLE_NAME," SET update_or_add='DELETE' WHERE instance<>DATABASE() AND update_or_add='INSERT'") FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_key_20200205';

CALL dt_wl_proceed_prepare_statement();

INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('CREATE TABLE z_newcreate_update_or_add ',GROUP_CONCAT(DISTINCT con_sql SEPARATOR ' UNION '),';') FROM (
SELECT GROUP_CONCAT(DISTINCT CONCAT('SELECT instance,comefrom_tableName,update_or_add,COUNT(*) num FROM ',TABLE_NAME,' WHERE update_or_add="INSERT" GROUP BY comefrom_tableName,instance,update_or_add') SEPARATOR ' UNION ') con_sql,'update_or_add' FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_key_20200205' GROUP BY TABLE_SCHEMA
UNION
SELECT GROUP_CONCAT(DISTINCT CONCAT('SELECT instance,comefrom_tableName,update_or_add,COUNT(*) num FROM ',TABLE_NAME,' WHERE update_or_add="DELETE" GROUP BY comefrom_tableName,instance,update_or_add') SEPARATOR ' UNION ') con_sql,'update_or_add' FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_key_20200205' GROUP BY TABLE_SCHEMA
UNION
SELECT GROUP_CONCAT(DISTINCT CONCAT('SELECT instance,comefrom_tableName,update_or_add,COUNT(*) num FROM ',TABLE_NAME,' WHERE update_or_add="UPDATE" and instance=DATABASE() GROUP BY comefrom_tableName,instance,update_or_add') SEPARATOR ' UNION ') con_sql,'update_or_add' FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%compare_%_key_20200205' GROUP BY TABLE_SCHEMA) a GROUP BY a.update_or_add;

CALL dt_wl_proceed_prepare_statement();

############################################################################################################################
#get the change column name, before and after data
############################################################################################################################
INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('INSERT INTO z_newcreate_all_option_infor ',GROUP_CONCAT(DISTINCT CONCAT("SELECT '",TABLE_NAME,"' table_name,key_value_data,CONCAT_WS('before: <','columnName: <",COLUMN_NAME,">, ',CONCAT(GROUP_CONCAT(DISTINCT IFNULL(`",COLUMN_NAME,"`,'') ORDER BY instance SEPARATOR '>, after: <'),'>')) update_infor,'UPDATE','' FROM ",TABLE_NAME," GROUP BY key_value_data HAVING COUNT(DISTINCT IFNULL(`",COLUMN_NAME,"`,''))>1") SEPARATOR ' UNION '),';') FROM information_schema.`COLUMNS` WHERE TABLE_NAME LIKE 'compare_%key_20200205' AND COLUMN_NAME NOT IN('allinfor','instance') AND TABLE_SCHEMA=DATABASE() GROUP BY TABLE_NAME
UNION
SELECT CONCAT("INSERT INTO z_newcreate_all_option_infor SELECT '",TABLE_NAME,"' tableName,key_value_data,CONCAT('",COLUMN_NAME,": ','<',`",COLUMN_NAME,"`,'>') add_infor,update_or_add,'' FROM ",TABLE_NAME," WHERE update_or_add='DELETE' AND LENGTH(TRIM(`",COLUMN_NAME,"`))>0;") FROM information_schema.`COLUMNS` WHERE TABLE_NAME LIKE 'compare_%key_20200205' AND COLUMN_NAME NOT IN('allinfor','instance','comefrom_tableName','update_or_add','key_value_data') AND TABLE_SCHEMA=DATABASE();

CALL dt_wl_proceed_prepare_statement();

#copy the table structure for insert record
INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('CREATE TABLE struct_',tableName,'_is_key_20200205 LIKE ',tableName,'') FROM z_newcreate_is_key_all_table GROUP BY tableName
UNION
SELECT CONCAT('CREATE TABLE struct_',tableName,'_no_key_20200205 LIKE ',tableName,'') FROM z_newcreate_no_key_all_table GROUP BY tableName
UNION
SELECT CONCAT('ALTER TABLE struct_',tableName,'_is_key_20200205 ADD COLUMN comefrom_tableName VARCHAR(255),ADD COLUMN allinfor VARCHAR(255),ADD COLUMN instance VARCHAR(25),ADD COLUMN update_or_add VARCHAR(25),ADD COLUMN key_value_data VARCHAR(255)') FROM z_newcreate_is_key_all_table GROUP BY tableName
UNION
SELECT CONCAT('ALTER TABLE struct_',tableName,'_no_key_20200205 ADD COLUMN comefrom_tableName VARCHAR(255),ADD COLUMN allinfor VARCHAR(255),ADD COLUMN instance VARCHAR(25),ADD COLUMN update_or_add VARCHAR(25),ADD COLUMN key_value_data VARCHAR(255)') FROM z_newcreate_no_key_all_table GROUP BY tableName
UNION
SELECT CONCAT('INSERT INTO ',REPLACE(TABLE_NAME,'compare_','struct_'),' SELECT ',GROUP_CONCAT(DISTINCT CONCAT('`',COLUMN_NAME,'`') ORDER BY ORDINAL_POSITION SEPARATOR ','),' FROM ',TABLE_NAME,' WHERE update_or_add="INSERT";') FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE 'compare_%_key_20200205' GROUP BY TABLE_NAME;

CALL dt_wl_proceed_prepare_statement();

INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT a.con_sql FROM (SELECT CONCAT("INSERT INTO z_newcreate_all_option_infor SELECT '",REPLACE(TABLE_NAME,'struct_','compare_'),"' tableName,key_value_data,CONCAT('",COLUMN_NAME,": ','<',`",COLUMN_NAME,"`,'>') add_infor,update_or_add,CONCAT('",COLUMN_NAME,": ','<','",COLUMN_DEFAULT,"','>') FROM ",TABLE_NAME," WHERE update_or_add<>'UPDATE' AND LENGTH(TRIM(`",COLUMN_NAME,"`))>0;") con_sql,TABLE_NAME,ORDINAL_POSITION FROM information_schema.`COLUMNS` WHERE TABLE_NAME LIKE 'struct_%key_20200205' AND COLUMN_NAME NOT IN('allinfor','instance','comefrom_tableName','update_or_add','key_value_data') AND TABLE_SCHEMA=DATABASE() AND COLUMN_KEY<>'PRI' AND LENGTH(TRIM(COLUMN_DEFAULT))>0 AND COLUMN_DEFAULT NOT IN ('d M Y H:i','0000-00-00','CURRENT_TIMESTAMP')
UNION
SELECT CONCAT("INSERT INTO z_newcreate_all_option_infor SELECT '",REPLACE(TABLE_NAME,'struct_','compare_'),"' tableName,key_value_data,CONCAT('",COLUMN_NAME,": ','<',`",COLUMN_NAME,"`,'>') add_infor,update_or_add,'' FROM ",TABLE_NAME," WHERE update_or_add<>'UPDATE' AND LENGTH(TRIM(`",COLUMN_NAME,"`))>0;") con_sql,TABLE_NAME,ORDINAL_POSITION FROM information_schema.`COLUMNS` WHERE TABLE_NAME LIKE 'struct_%key_20200205' AND COLUMN_NAME NOT IN('allinfor','instance','comefrom_tableName','update_or_add','key_value_data') AND TABLE_SCHEMA=DATABASE() AND COLUMN_KEY<>'PRI' AND LENGTH(TRIM(COLUMN_DEFAULT))>0 AND COLUMN_DEFAULT IN ('d M Y H:i','0000-00-00','CURRENT_TIMESTAMP')
UNION
SELECT CONCAT("INSERT INTO z_newcreate_all_option_infor SELECT '",REPLACE(TABLE_NAME,'struct_','compare_'),"' tableName,key_value_data,CONCAT('",COLUMN_NAME,": ','<',`",COLUMN_NAME,"`,'>') add_infor,update_or_add,'' FROM ",TABLE_NAME," WHERE update_or_add<>'UPDATE' AND LENGTH(TRIM(`",COLUMN_NAME,"`))>0;") con_sql,TABLE_NAME,ORDINAL_POSITION FROM information_schema.`COLUMNS` WHERE TABLE_NAME LIKE 'struct_%key_20200205' AND COLUMN_NAME NOT IN('allinfor','instance','comefrom_tableName','update_or_add','key_value_data') AND TABLE_SCHEMA=DATABASE() AND COLUMN_KEY<>'PRI' AND LENGTH(TRIM(COLUMN_DEFAULT))=0
UNION
SELECT CONCAT("INSERT INTO z_newcreate_all_option_infor SELECT '",REPLACE(TABLE_NAME,'struct_','compare_'),"' tableName,key_value_data,CONCAT('",COLUMN_NAME,": ','<',`",COLUMN_NAME,"`,'>') add_infor,update_or_add,'' FROM ",TABLE_NAME," WHERE update_or_add<>'UPDATE' AND LENGTH(TRIM(`",COLUMN_NAME,"`))>0;") con_sql,TABLE_NAME,ORDINAL_POSITION FROM information_schema.`COLUMNS` WHERE TABLE_NAME LIKE 'struct_%key_20200205' AND COLUMN_NAME NOT IN('allinfor','instance','comefrom_tableName','update_or_add','key_value_data') AND TABLE_SCHEMA=DATABASE() AND (COLUMN_DEFAULT IS NULL OR COLUMN_KEY='PRI') ORDER BY TABLE_NAME,ORDINAL_POSITION) a;

CALL dt_wl_proceed_prepare_statement();

INSERT INTO z_newcreate_prepare_statement_to_proceed(sql_stmt)
SELECT CONCAT('DROP TABLE ',TABLE_NAME,';') FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME LIKE '%struct_%_key_20200205';

CALL dt_wl_proceed_prepare_statement();

DELETE FROM z_newcreate_all_option_infor WHERE option_method='INSERT' AND LENGTH(TRIM(column_default_value))>0 AND column_default_value=update_infor;

############################################################################################################################
#dispaly the orignal table reference result table 显示插入/添加/删除的条数
############################################################################################################################
CREATE TABLE z_newcreate_update_or_add_final
SELECT DISTINCT tableName,1 isExist_PrimaryKey,CONCAT('SELECT * FROM compare_',tableName,'_is_key_20200205;') result_tableName FROM z_newcreate_is_key_all_table
UNION
SELECT DISTINCT tableName,0 isExist_PrimaryKey,CONCAT('SELECT * FROM compare_',tableName,'_no_key_20200205;') result_tableName FROM z_newcreate_no_key_all_table;

ALTER TABLE z_newcreate_update_or_add_final 
ADD COLUMN nowDatabase_insert_num VARCHAR(25) DEFAULT NULL,
ADD COLUMN database_update_num VARCHAR(25) DEFAULT NULL,
ADD COLUMN compareDatabase_delete_num VARCHAR(25) DEFAULT NULL;

UPDATE z_newcreate_update_or_add_final zf,z_newcreate_update_or_add zn SET zf.database_update_num=zn.num WHERE zf.tableName=zn.comefrom_tableName AND zn.update_or_add='UPDATE' AND zf.isExist_PrimaryKey=1;
UPDATE z_newcreate_update_or_add_final zf,z_newcreate_update_or_add zn SET zf.database_update_num='error' WHERE zf.tableName=zn.comefrom_tableName AND zn.update_or_add='UPDATE' AND zf.isExist_PrimaryKey=0;
UPDATE z_newcreate_update_or_add_final zf,z_newcreate_update_or_add zn SET zf.nowDatabase_insert_num=zn.num WHERE zf.tableName=zn.comefrom_tableName AND zn.instance=DATABASE() AND zn.update_or_add='INSERT';
UPDATE z_newcreate_update_or_add_final zf,z_newcreate_update_or_add zn SET zf.compareDatabase_delete_num=zn.num WHERE zf.tableName=zn.comefrom_tableName AND zn.instance<>DATABASE() AND zn.update_or_add='DELETE';

SELECT * FROM z_newcreate_update_or_add_final;

############################################################################################################################
#new add table    显示新增的表
############################################################################################################################
SELECT a.TABLE_SCHEMA,a.TABLE_NAME new_add_table FROM (SELECT * FROM z_newcreate_table_isExist_key 
UNION 
SELECT * FROM z_newcreate_table_isExist2_key) a GROUP BY a.TABLE_NAME HAVING COUNT(*)=1;

############################################################################################################################
#final display  显示具体发生变化的字段
############################################################################################################################
SELECT REPLACE(REPLACE(REPLACE(tableName,'compare_',''),'_is_key_20200205',''),'_no_key_20200205','') originalTable,option_method,CONCAT('[',GROUP_CONCAT(DISTINCT CONCAT('{',update_infor,'}') SEPARATOR ','),']') update_infor,tableName result_tableName,key_value_data,CONCAT('SELECT * FROM ',tableName,' WHERE key_value_data="',key_value_data,'";') con_sql FROM z_newcreate_all_option_infor GROUP BY tableName,key_value_data ORDER BY tableName,option_method;
COMMIT;
