USE [Support]
GO
/****** Object:  Trigger [dbo].[trgDELETE]    Script Date: 12/16/2015 11:49:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Zdon
-- Create date: 11/15/2015
-- =============================================
ALTER TRIGGER [dbo].[trgDELETE] 
   ON  [dbo].[prescriptions]
   FOR DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @prescriptpk int;
	declare @date date;
	declare @arcfk int;
	declare @OT bit;
	declare @PT bit;
	declare @PS bit;
	declare @SA bit;
	declare @EC bit;
	declare @NC bit;
	declare @reason varchar(30);
	declare @sentto varchar(40);
	declare @sentvia char(10);
	declare @datereceived date;
	declare @datesigned date;
	declare @comments varchar(max);
	declare @effbeg date;
	declare @effend date;
	declare @tablelock varchar(50);
	declare @empfk int;
	declare @documentation varchar(max);
    
	select @prescriptpk=d.prescriptpk from deleted d;	
	select @date=d.[date] from deleted d;	
	select @arcfk=d.arcfk from deleted d;
	select @OT=d.OT from deleted d;	
	select @PT=d.PT from deleted d;
	select @PS=d.PS from deleted d;	
	select @SA=d.SA from deleted d;
	select @EC=d.EC from deleted d;	
	select @NC=d.NC from deleted d;
	select @reason=d.reason from deleted d;	
	select @sentto=d.sentto from deleted d;
	select @sentvia=d.sentvia from deleted d;	
	select @datereceived=d.datereceived from deleted d;
	select @datesigned=d.datesigned from deleted d;	
	select @comments=d.comments from deleted d;	
	select @effbeg=d.effbeg from deleted d;
	select @effend=d.effend from deleted d;
	select @tablelock=d.tablelock from deleted d;	
	select @empfk=d.empfk from deleted d;	
	select @documentation=d.documentation from deleted d;	

		INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'prescriptpk',@prescriptpk,@prescriptpk,@empfk,@tablelock,'DELETE',GETDATE())

		INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'date',@date,@date,@empfk,@tablelock,'DELETE',GETDATE())

		INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'arcfk',@arcfk,@arcfk,@empfk,@tablelock,'DELETE',GETDATE())
       
       	INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'OT',@OT,@OT,@empfk,@tablelock,'DELETE',GETDATE())
       
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'PT',@PT,@PT,@empfk,@tablelock,'DELETE',GETDATE())
       
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'PS',@PS,@PS,@empfk,@tablelock,'DELETE',GETDATE())
       
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'SA',@SA,@SA,@empfk,@tablelock,'DELETE',GETDATE())
        
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'EC',@EC,@EC,@empfk,@tablelock,'DELETE',GETDATE())
                
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'NC',@NC,@NC,@empfk,@tablelock,'DELETE',GETDATE())
                                
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'reason',@reason,@reason,@empfk,@tablelock,'DELETE',GETDATE())
               
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'sentto',@sentto,@sentto,@empfk,@tablelock,'DELETE',GETDATE())
                 
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'sentvia',@sentvia,@sentvia,@empfk,@tablelock,'DELETE',GETDATE())
                     
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'datereceived',@datereceived,@datereceived,@empfk,@tablelock,'DELETE',GETDATE())
         
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'datesigned',@datesigned,@datesigned,@empfk,@tablelock,'DELETE',GETDATE())
                 
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'comments',@comments,@comments,@empfk,@tablelock,'DELETE',GETDATE())
                 
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'effbeg',@effbeg,@effbeg,@empfk,@tablelock,'DELETE',GETDATE())
                 
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'effend',@effend,@effend,@empfk,@tablelock,'DELETE',GETDATE())
                 
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'tablelock',@tablelock,@tablelock,@empfk,@tablelock,'DELETE',GETDATE())
                  
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'empfk',@empfk,@empfk,@empfk,@tablelock,'DELETE',GETDATE())
                  
        INSERT INTO [Audit].[dbo].[AUDITACT]
           ([databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[username],[action],[entrytime])
		VALUES
           ('Support','prescriptions',@prescriptpk,'documentation',@documentation,@documentation,@empfk,@tablelock,'DELETE',GETDATE())
                 
END