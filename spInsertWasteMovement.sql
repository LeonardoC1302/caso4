CREATE PROCEDURE InsertWasteMovement
    @posttime DATE,
    @responsibleName VARCHAR(50),
    @signImage VARBINARY(50),
    @addressId INT,
    @movementTypeId INT,
    @contractId INT,
    @quantity DECIMAL,
    @userId INT,
    @checksum VARBINARY(50),
    @computer VARCHAR(50),
    @containerId INT,
    @wasteId INT,
    @carId INT,
    @producerId INT
AS
BEGIN
    BEGIN TRANSACTION;
    INSERT INTO wasteMovements(posttime, responsibleName, signImage, addressId, movementTypeId, contractId, quantity, userId, checksum, computer, containerId, wasteId, carId) VALUES
        (@posttime, @responsibleName, @signImage, @addressId, @movementTypeId, @contractId, @quantity, @userId, @checksum, @computer, @containerId, @wasteId, @carId);
    
    INSERT INTO producersXmovements(producerId, wasteMovementId) VALUES
        (@producerId, (SELECT TOP 1 wasteMovementId FROM wasteMovements ORDER BY wasteMovementId DESC));

    WAITFOR DELAY '00:00:05'

    COMMIT
END
