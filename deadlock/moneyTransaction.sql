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
            // Deadlock podría ocurrir cuando un participant A le manda X cantidad a un participant B y al mismo tiempo
            // el participant B le manda Y cantidad al participant A 
                UPDATE participants
                SET balance = balance - @amount where participantId = @senderId;
                INSERT INTO [dbo].[transactions] ([amount],[transactionDescription],[transactionTypeId] ,[transactionDate])
                VALUES (@amount, 'Money Transaction', 1, GETDATE());
                WAITFOR DELAY '00:00:10';
                UPDATE participants
                SET balance = balance + @amount where participantId = @receiverId;
			COMMIT TRANSACTION
		END
END