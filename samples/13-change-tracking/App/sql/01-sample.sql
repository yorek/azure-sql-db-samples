select * from dbo.TrainingSessions
go

-- Insert sample values
insert into dbo.TrainingSessions 
    (RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    (sysdatetimeoffset(), 'Run', 4123, 4234, 30*60+23, 411),
    (sysdatetimeoffset(), 'Run', 4568, 4780, 30*60+44, 4890);
go

