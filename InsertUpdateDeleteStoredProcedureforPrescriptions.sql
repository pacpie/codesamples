USE [Support]
GO
/****** Object:  StoredProcedure [dbo].[prescriptions_InsertUpdateDelete]    Script Date: 12/03/2015 07:48:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Zdon, William
-- Create date: 11/18/2015
-- Description:	Stored Procedure to handle Insert/Update/Delete for Prescriptions page
-- =============================================
CREATE PROCEDURE [dbo].[prescriptions_InsertUpdateDelete]
-- Add the parameters for the stored procedure here
(@Action VARCHAR(14),@prescriptpk int,@date date, @arcfk int, @OT bit, @PT bit, @PS bit, @SA bit, @EC bit, @NC bit, @reason varchar(30), @sentto varchar(40), @sentvia char(10), @datereceived date, @datesigned date, @comments varchar(max), @effbeg date, @effend date, @tablelock varchar(50), @empfk int, @documentation varchar(max))
AS
IF @Action = 'DELETE'
--DELETE RECORD
	BEGIN
		UPDATE prescriptions SET empfk = @empfk, tablelock = @tablelock WHERE prescriptpk = @prescriptpk
        DELETE FROM    [dbo].[prescriptions]
        WHERE   [prescriptpk] = @prescriptpk
	END
ELSE 
	--Insert or Update
	BEGIN
		IF @prescriptpk IS NULL or @prescriptpk = '' 
		--Insert record
		BEGIN
			SET NOCOUNT ON;
			INSERT INTO [dbo].[prescriptions]
			([date],[arcfk],[OT],[PT],[PS],[SA],[EC],[NC],[reason],[sentto],
			[sentvia],[datereceived],[datesigned],[comments],[effbeg],[effend],[tablelock],[empfk],
			[documentation])
			VALUES
			(@date,@arcfk,@OT,@PT,@PS,@SA,@EC,@NC,@reason,@sentto,@sentvia,
			@datereceived,@datesigned,@comments,@effbeg,@effend,@tablelock,@empfk,@documentation)
			SET @prescriptpk = SCOPE_IDENTITY();
		END
	ELSE
		--Update record
		BEGIN	
		  UPDATE [Support].[dbo].[prescriptions]     --UPDATE RECORD
		  SET [date]=@date, arcfk=@arcfk, OT=@OT, PT=@PT,
		  PS=@PS, SA=@SA, EC=@EC, NC=@NC, reason=@reason, sentto=@sentto, sentvia=@sentvia,
		  datereceived=@datereceived, datesigned=@datesigned, comments=@comments,
		  effbeg=@effbeg, effend=@effend, tablelock=@tablelock, empfk=@empfk, documentation=@documentation
		  WHERE prescriptpk=@prescriptpk
		END
	END