################################################################################################################################
#                                     automerge 账号错误合并涉及的duplicate相关表的处理
#                                                        关联work-15177
################################################################################################################################

################################################################################################################################
#duplicate_merge_history  记录参与合并的账号
################################################################################################################################
#keepAccountId:    需保留账号的accountId
#purgeAccountId:   被合并账号的accountId
#currentAccountId: 最终合并的accountId  
#keepAccountName:  需保留账号的名字
#purgeAccountName: 被合并账号的名字
#keepUserId：  需保留账号的userId
#purgeUserId： 被合并账号的userId
#autoMerge：   (1,autoMerge)
SELECT * FROM duplicate_merge_history;

################################################################################################################################
#duplicate_list_items  记录的合并的账号按什么方式参与的合并
################################################################################################################################
#userIds: 用逗号拼接的合并账号的userId
#listId: (1,email merge), (2,name + email merge), (3,address merge), (4,name + address merge)
#isMerge: (1,autoMerge)
SELECT * FROM duplicate_list_items;

################################################################################################################################
#duplicate_merge_history_section 记录的合并的账号下面有哪些模块信息，
################################################################################################################################
#mergeId: duplicate_merge_history.id
#accountType: (1,代表keepAccount合并前账号有哪些模块), (2,代表purgeAccount合并前账号有哪些模块), (3,代表合并后账号的所有模块)
#sectionType: account_detail_sections.id
SELECT * FROM duplicate_merge_history_section;

################################################################################################################################
#duplicate_merge_history_line  记录的合并的账号所属模块内的详细内容(包含合并前两个账号的模块内的详细内容和合并后最终账号的模块内的详细内容)
################################################################################################################################
#sectionId: duplicate_merge_history_section.id
SELECT * FROM duplicate_merge_history_line;


################################################################################################################################
#对于账号错误合并只出现一次的情况-------(即B合到了错误的A上面，且A没有再与其他账号参与合并)
################################################################################################################################
DELETE FROM duplicate_merge_history_line WHERE sectionId IN(SELECT id FROM duplicate_merge_history_section WHERE mergeId IN(SELECT id FROM duplicate_merge_history WHERE .......));

DELETE FROM duplicate_merge_history_section WHERE mergeId IN(SELECT id FROM duplicate_merge_history WHERE .......);

DELETE FROM duplicate_list_items WHERE userIds IN(SELECT CONCAT_WS(',',keepUserId,purgeUserId) FROM duplicate_merge_history WHERE ....... UNION SELECT CONCAT_WS(',',purgeUserId,keepUserId) FROM duplicate_merge_history WHERE .......);

DELETE FROM duplicate_merge_history WHERE .......;


################################################################################################################################
#对于账号错误合并出现多次的情况 需要看情况删除不正确的历史记录，重构新的历史记录，
################################################################################################################################
