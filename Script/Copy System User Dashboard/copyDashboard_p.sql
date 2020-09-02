DROP FUNCTION IF EXISTS dt_wl_parse_string;
DROP PROCEDURE IF EXISTS bwh_dt_copy_dashboard;

DELIMITER //

CREATE DEFINER=`root`@`%` FUNCTION `dt_wl_parse_string`(f_string VARCHAR(10000),f_delimiter VARCHAR(10),f_order int) RETURNS varchar(10000) CHARSET utf8
    DETERMINISTIC
BEGIN
  DECLARE result VARCHAR(10000) DEFAULT '';
  DECLARE f_delimiter_length INT;
  DECLARE optionCount INT;
  SET f_delimiter_length=LENGTH(f_delimiter);
  SET optionCount=(LENGTH(f_string)-LENGTH(REPLACE(f_string,f_delimiter,'')))/f_delimiter_length +2;

IF f_order < optionCount AND f_order>0 THEN
  SET result = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(f_string,f_delimiter,f_order),f_delimiter,-1));
END IF;

IF result=f_delimiter OR LENGTH(TRIM(result))=0 THEN SET result= NULL;
END IF;

  RETURN result;

END //

CREATE DEFINER = `root`@`%` PROCEDURE `bwh_dt_copy_dashboard`(`originalUserId` varchar(25),`targetUserId` varchar(25),`dashboardType` varchar(25))
BEGIN
DECLARE num1 INT DEFAULT 1;
DECLARE num2 INT DEFAULT NULL;
SET num2=LENGTH(dashboardType)-LENGTH(REPLACE(dashboardType,',',''))+1;

DROP TABLE IF EXISTS z_newcreate_dsh_dashboard_copy_20200512;
CREATE TABLE z_newcreate_dsh_dashboard_copy_20200512 LIKE dsh_dashboard;
DROP TABLE IF EXISTS z_newcreate_dsh_dashboard_delete_20200512;
CREATE TABLE z_newcreate_dsh_dashboard_delete_20200512 LIKE dsh_dashboard;

WHILE num1 <= num2 DO

INSERT INTO z_newcreate_dsh_dashboard_copy_20200512
SELECT * FROM dsh_dashboard WHERE userId=originalUserId AND type IN(SELECT dt_wl_parse_string(dashboardType,',',num1));

INSERT INTO z_newcreate_dsh_dashboard_delete_20200512
SELECT * FROM dsh_dashboard WHERE userId=targetUserId AND type IN(SELECT dt_wl_parse_string(dashboardType,',',num1));

SET num1:=num1+1;

END WHILE;

##########################################################################################################################
#                            copy one system user dashboard to other system user
#
#                                                  CC-3459,CC-2735,CC-3059
#
##########################################################################################################################
DROP TABLE IF EXISTS
z_newcreate_dsh_dashboard_insert_20200512,
z_newcreate_dsh_dashboard_widget_copy_20200512,
z_newcreate_dsh_dashboard_widget_delete_20200512,
z_newcreate_dsh_dashboard_widget_insert_20200512,
z_newcreate_dsh_dashboard_widget_output_copy_20200512,
z_newcreate_dsh_dashboard_widget_output_delete_20200512,
z_newcreate_dsh_dashboard_widget_output_insert_20200512,
z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512,
z_newcreate_dsh_dashboard_widget_search_criteria_delete_20200512,
z_newcreate_dsh_dashboard_widget_search_criteria_insert_20200512;

##########################################################################################################################
#copy fundraising dashboard(copy system user)
#type: Mission Control(1), ACCOUNT(2), FUNDRAISING (3), MEMBERSHIP (4), EVENT(5), REPORT(6), Email(7), STORE(8), DOCUMENT(9) 最后一个type=9 的还没有这个功能
##########################################################################################################################
CREATE TABLE z_newcreate_dsh_dashboard_widget_copy_20200512
SELECT dd.* FROM dsh_dashboard_widget dd JOIN z_newcreate_dsh_dashboard_copy_20200512 zn ON dd.dashboardId=zn.id;

CREATE TABLE z_newcreate_dsh_dashboard_widget_output_copy_20200512
SELECT dd.* FROM dsh_dashboard_widget_output dd JOIN z_newcreate_dsh_dashboard_widget_copy_20200512 zn ON dd.dashboardWidgetId=zn.id;

CREATE TABLE z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512
SELECT dd.* FROM dsh_dashboard_widget_search_criteria dd JOIN z_newcreate_dsh_dashboard_widget_copy_20200512 zn ON dd.dashboardWidgetId=zn.id;

##########################################################################################################################
#delete dafault fundraising dashboard(other system user)
##########################################################################################################################
CREATE TABLE z_newcreate_dsh_dashboard_widget_delete_20200512
SELECT dd.* FROM dsh_dashboard_widget dd JOIN z_newcreate_dsh_dashboard_delete_20200512 zn WHERE dd.dashboardId=zn.id;

CREATE TABLE z_newcreate_dsh_dashboard_widget_output_delete_20200512
SELECT dd.* FROM dsh_dashboard_widget_output dd JOIN z_newcreate_dsh_dashboard_widget_delete_20200512 zn WHERE dd.dashboardWidgetId=zn.id;

CREATE TABLE z_newcreate_dsh_dashboard_widget_search_criteria_delete_20200512
SELECT dd.* FROM dsh_dashboard_widget_search_criteria dd JOIN z_newcreate_dsh_dashboard_widget_delete_20200512 zn WHERE dd.dashboardWidgetId=zn.id;

DELETE dd.* FROM dsh_dashboard_widget_search_criteria dd JOIN z_newcreate_dsh_dashboard_widget_search_criteria_delete_20200512 zn ON dd.id=zn.id;
DELETE dd.* FROM dsh_dashboard_widget_output dd JOIN z_newcreate_dsh_dashboard_widget_output_delete_20200512 zn ON dd.id=zn.id;
DELETE dd.* FROM dsh_dashboard_widget dd JOIN z_newcreate_dsh_dashboard_widget_delete_20200512 zn ON dd.id=zn.id;
DELETE dd.* FROM dsh_dashboard dd JOIN z_newcreate_dsh_dashboard_delete_20200512 zn ON dd.id=zn.id;

##########################################################################################################################
#import dsh_dashboard
##########################################################################################################################
CREATE TABLE z_newcreate_dsh_dashboard_insert_20200512
SELECT zn.id,u.userId,zn.type,zn.defaultDashboard,zn.id oldId FROM z_newcreate_dsh_dashboard_copy_20200512 zn JOIN (SELECT userId FROM user WHERE userType=2 AND userId=targetUserId) u ORDER BY u.userId,zn.id;

SELECT IFNULL(max(id+0),0) FROM dsh_dashboard INTO @dshId;
UPDATE z_newcreate_dsh_dashboard_insert_20200512 SET id=(@dshId:=@dshId+1);

INSERT INTO dsh_dashboard(id,userId,type,defaultDashboard)
SELECT id,userId,type,defaultDashboard FROM z_newcreate_dsh_dashboard_insert_20200512;

##########################################################################################################################
#import dsh_dashboard_widget
##########################################################################################################################
CREATE TABLE z_newcreate_dsh_dashboard_widget_insert_20200512
SELECT zn.id,zn.title,zn2.Id dashboardId,zn.systemWidgetId,zn.`columns`,zn.pageSize,zn.displayOrder,zn.enablePosting,zn.sortField,zn.sortDirection,zn.id oldId FROM z_newcreate_dsh_dashboard_widget_copy_20200512 zn JOIN z_newcreate_dsh_dashboard_insert_20200512 zn2 ON zn.dashboardId=zn2.oldId ORDER BY zn2.Id;

SELECT IFNULL(max(id+0),0) FROM dsh_dashboard_widget INTO @dshId;
UPDATE z_newcreate_dsh_dashboard_widget_insert_20200512 SET id=(@dshId:=@dshId+1);

INSERT INTO dsh_dashboard_widget(id,title,dashboardId,systemWidgetId,`columns`,pageSize,displayOrder,enablePosting,sortField,sortDirection)
SELECT id,title,dashboardId,systemWidgetId,`columns`,pageSize,displayOrder,enablePosting,sortField,sortDirection FROM z_newcreate_dsh_dashboard_widget_insert_20200512;

##########################################################################################################################
#import dsh_dashboard_widget_output
##########################################################################################################################
CREATE TABLE z_newcreate_dsh_dashboard_widget_output_insert_20200512
SELECT zn.id,zn2.Id dashboardWidgetId,zn.systemOutputId,zn.displayOrder,zn.selected,zn.id oldId FROM z_newcreate_dsh_dashboard_widget_output_copy_20200512 zn JOIN z_newcreate_dsh_dashboard_widget_insert_20200512 zn2 ON zn.dashboardWidgetId=zn2.oldId ORDER BY zn2.Id;

SELECT IFNULL(max(id+0),0) FROM dsh_dashboard_widget_output INTO @dshId;
UPDATE z_newcreate_dsh_dashboard_widget_output_insert_20200512 SET id=(@dshId:=@dshId+1);

INSERT INTO dsh_dashboard_widget_output(id,dashboardWidgetId,systemOutputId,displayOrder,selected)
SELECT id,dashboardWidgetId,systemOutputId,displayOrder,selected FROM z_newcreate_dsh_dashboard_widget_output_insert_20200512;

##########################################################################################################################
#import dsh_dashboard_widget_search_criteria
##########################################################################################################################
CREATE TABLE z_newcreate_dsh_dashboard_widget_search_criteria_insert_20200512
SELECT zn.id,zn2.Id dashboardWidgetId,zn.systemCriteriaId,zn.`value`,zn.`enable`,zn.id oldId FROM z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512 zn JOIN z_newcreate_dsh_dashboard_widget_insert_20200512 zn2 ON zn.dashboardWidgetId=zn2.oldId ORDER BY zn2.Id;

SELECT IFNULL(max(id+0),0) FROM dsh_dashboard_widget_search_criteria INTO @dshId;
UPDATE z_newcreate_dsh_dashboard_widget_search_criteria_insert_20200512 SET id=(@dshId:=@dshId+1);

INSERT INTO dsh_dashboard_widget_search_criteria(id,dashboardWidgetId,systemCriteriaId,`value`,`enable`)
SELECT id,dashboardWidgetId,systemCriteriaId,`value`,`enable` from z_newcreate_dsh_dashboard_widget_search_criteria_insert_20200512;

END //

DELIMITER ;

##########################################################################################################################
#originalUserId:需要拷贝dashboard账号的userId
#targetUserId:拷贝到对应账号上的userId
#dashboardType:Mission Control(1), ACCOUNT(2), FUNDRAISING (3), MEMBERSHIP (4), EVENT(5), REPORT(6), Email(7), STORE(8), DOCUMENT(9) 最后一个type=9 的还没有这个功能,传参支持多个，但是需要用逗号拼接
##########################################################################################################################
CALL bwh_dt_copy_dashboard('4','5','1,2');
CALL bwh_dt_copy_dashboard('4','3','1,2');

DROP PROCEDURE IF EXISTS bwh_dt_parse_dashboard;
DROP FUNCTION IF EXISTS dt_wl_parse_string;
