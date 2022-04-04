/*
select 'drop table [dbo].[' + [name] + ']' from sys.tables where [name] like 'scope_info%' and schema_id = 1
union all
select 'drop procedure [dbo].[' + [name] + ']' from sys.procedures where [name] like 'TrainingSessions%' and schema_id = 1
*/

drop table [dbo].[scope_info_history]
drop table [dbo].[scope_info_server]
drop procedure [dbo].[TrainingSessions_bulkdelete]
drop procedure [dbo].[TrainingSessions_bulkupdate]
drop procedure [dbo].[TrainingSessions_changes]
drop procedure [dbo].[TrainingSessions_delete]
drop procedure [dbo].[TrainingSessions_deletemetadata]
drop procedure [dbo].[TrainingSessions_initialize]
drop procedure [dbo].[TrainingSessions_reset]
drop procedure [dbo].[TrainingSessions_selectrow]
drop procedure [dbo].[TrainingSessions_update]