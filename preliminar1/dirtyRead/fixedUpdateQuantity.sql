CREATE PROCEDURE UpdateProductQuantity
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    BEGIN TRANSACTION

    -- Update the product quantity
    UPDATE inventoryProduct
    SET quantity = quantity + @Quantity
    WHERE "productId" = @ProductId

    WAITFOR DELAY '00:00:05'

    IF @Quantity > 50
        ROLLBACK
    ELSE
        COMMIT
END
