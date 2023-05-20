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
    -- Escenario: Actualizaciones concurrentes
    -- Si otra transacción modifica la tabla inventoryProduct después de hacerle read al @availableStock, pero antes de realizar el UPDATE inventoryProduct
    -- se puede producir un dirty read.
    DECLARE @sellerPercentage DECIMAL(5,2);
    DECLARE @producerPercentage DECIMAL(5,2);
    DECLARE @collectorPercentage DECIMAL(5,2);
    DECLARE @availableStock INT;

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

    SET @availableStock = (
        SELECT TOP 1 inventoryProduct.quantity 
        FROM inventoryProduct 
        WHERE productId = @product
    );

    IF (@availableStock >= @quantity) 
    BEGIN
        -- Introduce a delay to simulate concurrent transaction modifying the data
        WAITFOR DELAY '00:00:05'; -- Wait for 5 seconds (adjust as needed)

        UPDATE inventoryProduct 
        SET quantity = quantity - @quantity 
        WHERE productId = @product; 

        INSERT INTO [dbo].[sales]
            ([clientId], [productId], [sellerId], [totalPrice], [posttime], [checksum], [paymentTypeId], [contractId], [quantity])
        VALUES
            (@client, @product, @seller, @totalPrice, GETDATE(), NULL, @paymentType, @contract, @quantity);

        SET @sellerPercentage = (
            SELECT participantPercentage 
            FROM contractParticipants
            INNER JOIN contracts ON contractParticipants.contractId = contracts.contractId
            WHERE contractParticipants.contractId = @contract 
                AND contractParticipants.participantId = @seller
        );

        -- Update seller's balance
        UPDATE participants
        SET balance = balance + @totalPrice * (@sellerPercentage/100)
        WHERE participantId = @seller;

        -- Update producers balance
        UPDATE producers
        SET balance = balance + @totalPrice * (contractProducers.producerPercentage / 100)
        FROM contracts
        INNER JOIN contractProducers ON contracts.contractId = contractProducers.contractId
        INNER JOIN producers ON contractProducers.producerId = producers.producerId
        WHERE contracts.contractId = @contract;

        -- Update collectors balance
        UPDATE collectors
        SET balance = balance + @totalPrice * (contractCollectors.collectorPercentage / 100)
        FROM contracts
        INNER JOIN contractCollectors ON contracts.contractId = contractCollectors.contractId
        INNER JOIN collectors ON contractCollectors.collectorId = collectors.collectorId
        WHERE contracts.contractId = @contract;
    END;
END;
