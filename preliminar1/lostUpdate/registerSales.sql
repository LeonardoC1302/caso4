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
        -- Si varias instancias de este procedimiento almacenado se ejecutan simultáneamente y actualizan el mismo @producto,
        -- existe la posibilidad de que se pierdan actualizaciones cuando una actualización sobrescribe los cambios realizados por otra instancia.
        DECLARE @sellerPercentage decimal(5,2);
        DECLARE @producerPercentage decimal(5,2);
        DECLARE @collectorPercentage decimal(5,2);
		DECLARE @availableStock int;

		set @availableStock = (Select top 1 inventoryProduct.quantity FROM inventoryProduct WHERE productId = @product);

		IF(@availableStock >= @quantity) 
		BEGIN
            WAITFOR DELAY '00:00:05'
			UPDATE inventoryProduct SET quantity = @availableStock - @quantity WHERE productId = @product; 

        INSERT INTO [dbo].[sales]([clientId], [productId], [sellerId], [totalPrice], [posttime], [checksum], [paymentTypeId], [contractId], [quantity]) VALUES
            (@client, @product, @seller, @totalPrice, GETDATE(), NULL, @paymentType, @contract, @quantity);


        SET @sellerPercentage = (SELECT participantPercentage FROM contractParticipants
            INNER JOIN contracts ON contractParticipants.contractId = contracts.contractId
            WHERE contractParticipants.contractId = @contract AND 
                contractParticipants.participantId = @seller);

        -- Update seller's balance
        UPDATE participants
            SET participants.balance = participants.balance + @totalPrice * (@sellerPercentage/100)
            where participants.participantId = @seller;
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
    END;