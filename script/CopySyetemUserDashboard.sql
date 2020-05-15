
##########################################################################################################################
#                            copy one system user dashboard to another system user
#                                                  
#                                                  CC-3459
#
##########################################################################################################################
DROP TABLE if EXISTS 
z_newcreate_dsh_dashboard_copy_20200512,
z_newcreate_dsh_dashboard_delete_20200512,
z_newcreate_dsh_dashboard_widget_copy_20200512,
z_newcreate_dsh_dashboard_widget_delete_20200512,
z_newcreate_dsh_dashboard_widget_output_copy_20200512,
z_newcreate_dsh_dashboard_widget_output_delete_20200512,
z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512,
z_newcreate_dsh_dashboard_widget_search_criteria_delete_20200512;

##########################################################################################################################
#copy fundraising dashboard(copy system user)
#type: Mission Control(1), ACCOUNT(2), FUNDRAISING (3), MEMBERSHIP (4), EVENT(5), REPORT(6), Email(7), STORE(8), DOCUMENT(9) 最后一个type=9 的还没有这个功能
##########################################################################################################################
CREATE TABLE z_newcreate_dsh_dashboard_copy_20200512
SELECT * from dsh_dashboard where userId in(3) and type=3;

CREATE TABLE z_newcreate_dsh_dashboard_widget_copy_20200512
SELECT * from dsh_dashboard_widget where dashboardId in (SELECT id from z_newcreate_dsh_dashboard_copy_20200512);

CREATE TABLE z_newcreate_dsh_dashboard_widget_output_copy_20200512
SELECT * from dsh_dashboard_widget_output WHERE dashboardWidgetId in (SELECT id from z_newcreate_dsh_dashboard_widget_copy_20200512);

CREATE TABLE z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512
SELECT * from dsh_dashboard_widget_search_criteria where dashboardWidgetId in (SELECT id from z_newcreate_dsh_dashboard_widget_copy_20200512);

##########################################################################################################################
#delete dafault fundraising dashboard(aother system user)
##########################################################################################################################
CREATE TABLE z_newcreate_dsh_dashboard_delete_20200512
SELECT * from dsh_dashboard where userId in(9811) and type=3;

CREATE TABLE z_newcreate_dsh_dashboard_widget_delete_20200512
SELECT * from dsh_dashboard_widget where dashboardId in (SELECT id from z_newcreate_dsh_dashboard_delete_20200512);

CREATE TABLE z_newcreate_dsh_dashboard_widget_output_delete_20200512
SELECT * from dsh_dashboard_widget_output WHERE dashboardWidgetId in (SELECT id from z_newcreate_dsh_dashboard_widget_delete_20200512);

CREATE TABLE z_newcreate_dsh_dashboard_widget_search_criteria_delete_20200512
SELECT * from dsh_dashboard_widget_search_criteria where dashboardWidgetId in (SELECT id from z_newcreate_dsh_dashboard_widget_delete_20200512);

DELETE from dsh_dashboard_widget_search_criteria where id in (SELECT id from z_newcreate_dsh_dashboard_widget_search_criteria_delete_20200512);
DELETE from dsh_dashboard_widget_output where id in (SELECT id from z_newcreate_dsh_dashboard_widget_output_delete_20200512);
DELETE from dsh_dashboard_widget where id in (SELECT id from z_newcreate_dsh_dashboard_widget_delete_20200512);
DELETE from dsh_dashboard where id in (SELECT id from z_newcreate_dsh_dashboard_delete_20200512);

##########################################################################################################################
#insert copy fundraising dashboard
##########################################################################################################################
UPDATE z_newcreate_dsh_dashboard_copy_20200512 set userId=9811;

ALTER TABLE z_newcreate_dsh_dashboard_copy_20200512 add oldId int DEFAULT null;

UPDATE z_newcreate_dsh_dashboard_copy_20200512 set oldId=id;

SELECT IFNULL(max(id+0),0) from dsh_dashboard into @dshId;

UPDATE z_newcreate_dsh_dashboard_copy_20200512 set id=(@dshId:=@dshId+1);

insert INTO dsh_dashboard(id,userId,type,defaultDashboard)
SELECT id,userId,type,defaultDashboard from z_newcreate_dsh_dashboard_copy_20200512;

##########################################################################################################################
#import dsh_dashboard_widget
##########################################################################################################################

UPDATE z_newcreate_dsh_dashboard_widget_copy_20200512 zjd, z_newcreate_dsh_dashboard_copy_20200512 zj set zjd.dashboardId=zj.id where zjd.dashboardId=zj.oldId;

ALTER TABLE z_newcreate_dsh_dashboard_widget_copy_20200512 add oldId int DEFAULT null;

UPDATE z_newcreate_dsh_dashboard_widget_copy_20200512 set oldId=id;

SELECT IFNULL(max(id+0),0) from dsh_dashboard_widget into @dshId;

UPDATE z_newcreate_dsh_dashboard_widget_copy_20200512 set id=(@dshId:=@dshId+1);

insert into dsh_dashboard_widget (id,title,dashboardId,systemWidgetId,columns,pageSize,displayOrder,enablePosting,sortField,sortDirection)
SELECT id,title,dashboardId,systemWidgetId,columns,pageSize,displayOrder,enablePosting,sortField,sortDirection from z_newcreate_dsh_dashboard_widget_copy_20200512;

##########################################################################################################################
UPDATE z_newcreate_dsh_dashboard_widget_output_copy_20200512 zjd, z_newcreate_dsh_dashboard_widget_copy_20200512 zj set zjd.dashboardWidgetId=zj.id where zjd.dashboardWidgetId=zj.oldId;
UPDATE z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512 zjd, z_newcreate_dsh_dashboard_widget_copy_20200512 zj set zjd.dashboardWidgetId=zj.id where zjd.dashboardWidgetId=zj.oldId;

##########################################################################################################################
#import dsh_dashboard_widget_output
##########################################################################################################################

ALTER TABLE z_newcreate_dsh_dashboard_widget_output_copy_20200512 add oldId int DEFAULT null;

UPDATE z_newcreate_dsh_dashboard_widget_output_copy_20200512 set oldId=id;

SELECT IFNULL(max(id+0),0) from dsh_dashboard_widget_output into @dshId;

UPDATE z_newcreate_dsh_dashboard_widget_output_copy_20200512 set id=(@dshId:=@dshId+1);

insert into dsh_dashboard_widget_output (id,dashboardWidgetId,systemOutputId,displayOrder,selected)
SELECT id,dashboardWidgetId,systemOutputId,displayOrder,selected from z_newcreate_dsh_dashboard_widget_output_copy_20200512;

##########################################################################################################################
#import dsh_dashboard_widget_search_criteria
##########################################################################################################################
ALTER TABLE z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512 add oldId int DEFAULT null;

UPDATE z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512 set oldId=id;

SELECT IFNULL(max(id+0),0) from dsh_dashboard_widget_search_criteria into @dshId;

UPDATE z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512 set id=(@dshId:=@dshId+1);

insert into dsh_dashboard_widget_search_criteria (id,dashboardWidgetId,systemCriteriaId,value,enable)
SELECT id,dashboardWidgetId,systemCriteriaId,value,enable from z_newcreate_dsh_dashboard_widget_search_criteria_copy_20200512;

##########################################################################################################################
update organization_bio set calculateFiscalStats = 1;

commit;
