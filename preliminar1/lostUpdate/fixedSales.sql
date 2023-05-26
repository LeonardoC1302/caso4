-- SQLBook: Code
CREATE PROCEDURE [dbo].[registerSales] 
    @client INT,
    @product INT,
    @seller INT,
    @totalPrice DECIMAL(12,2),
    @paymentType INT,
    @contract INT,
    @quantity INT
AS
BEGIN 
    -- 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;' permite que las transaccciones concurrentes se serialicen adecuadamente
    -- Se añade un BEGIN TRANSACTION y COMMIT para definir el inicio y fin de la transacción explícitamente y que el sp se trate como una sola unidad atómica en la ejecución
    BEGIN TRANSACTION;

    DECLARE @sellerPercentage decimal(5,2);
    DECLARE @producerPercentage decimal(5,2);
    DECLARE @collectorPercentage decimal(5,2);
    DECLARE @availableStock int;

    -- UPDLOCK añade un lock exclusivo a la fila que se está leyendo, lo cual evita que otras transacciones concurrentes puedan leerla o modificarla antes de que se termine la transacción actual
    SET @availableStock = (SELECT TOP 1 inventoryProduct.quantity FROM inventoryProduct WHERE productId = @product);

    IF(@availableStock >= @quantity) 
    BEGIN
        WAITFOR DELAY '00:00:05'
        UPDATE inventoryProduct SET quantity = quantity - @quantity WHERE productId = @product; 
        IF @Quantity < 0
            ROLLBACK
        INSERT INTO [dbo].[sales]([clientId], [productId], [sellerId], [totalPrice], [posttime], [checksum], [paymentTypeId], [contractId], [quantity]) 
        VALUES (@client, @product, @seller, @totalPrice, GETDATE(), NULL, @paymentType, @contract, @quantity);

        SET @sellerPercentage = (SELECT participantPercentage FROM contractParticipants
            INNER JOIN contracts ON contractParticipants.contractId = contracts.contractId
            WHERE contractParticipants.contractId = @contract AND 
            contractParticipants.participantId = @seller);

        -- Update seller's balance
        UPDATE participants
        SET participants.balance = participants.balance + @totalPrice * (@sellerPercentage/100)
        WHERE participants.participantId = @seller;

        -- Update producers balance
        UPDATE producers
        SET producers.balance = producers.balance + @totalPrice * (contractProducers.producerPercentage / 100)
        FROM contracts
        INNER JOIN contractProducers ON contracts.contractId = contractProducers.contractId
        INNER JOIN producers ON contractProducers.producerId = producers.producerId
        WHERE contracts.contractId = @contract;

        -- Update collectors balance
        UPDATE collectors
        SET collectors.balance = collectors.balance + @totalPrice * (contractCollectors.collectorPercentage / 100)
        FROM contracts
        INNER JOIN contractCollectors ON contracts.contractId = contractCollectors.contractId
        INNER JOIN collectors ON contractCollectors.collectorId = collectors.collectorId
        WHERE contracts.contractId = @contract;
    END;

    COMMIT;
END;
