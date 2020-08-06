
###############################################################################################################################
#
#
#                                             批量删除保存的报表涉及的表
#
#
###############################################################################################################################
report_config (id,name,searchCriteria)

report_enabled  ( config   ==》   report_config.id)

report_output  ( reportId   ==》   report_config.id)

search_criteria  ( id   ==》   report_config.searchCriteria)

search_token (  searchCriteriaId  ==》   report_config.searchCriteria)

(Note: 对于report_config 表中audienceReport, objectId, workflowReport这三个字段不是默认值，可能会有其他的表受影响，需与开发确认)