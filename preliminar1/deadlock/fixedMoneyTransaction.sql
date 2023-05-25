-- SQLBook: Code
CREATE PROCEDURE moneyTransaction
	@senderId INT,
    @receiverId INT,
    @amount decimal(18, 2)
AS
BEGIN
	DECLARE @senderAmount decimal(18, 2);
	SET @senderAmount = (SELECT balance FROM participants WHERE participantId = @senderId);
	if(@senderAmount>= @amount)
		BEGIN
			BEGIN TRANSACTION
			UPDATE participants
			SET balance = CASE
				WHEN participantId = @senderId THEN balance - @amount
				WHEN participantId = @receiverId THEN balance + @amount
				ELSE balance
				END
			WHERE participantId IN (@senderId, @receiverId);

			INSERT INTO [dbo].[transactions] ([amount],[transactionDescription],[transactionTypeId] ,[transactionDate])
			VALUES (@amount, 'Money Transaction', 1, GETDATE());
			WAITFOR DELAY '00:00:10';
			
			COMMIT TRANSACTION
		END
END