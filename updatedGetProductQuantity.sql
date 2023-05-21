CREATE PROCEDURE GetProductQuantity
    @ProductId INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    BEGIN TRANSACTION

    WAITFOR DELAY '00:00:03'
    -- Read the product quantity
    SELECT Quantity
    FROM inventoryProduct
    WHERE productId = @ProductId

    -- Commit the transaction
    COMMIT
END
