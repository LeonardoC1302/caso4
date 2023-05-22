CREATE PROCEDURE addProduct
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    BEGIN TRANSACTION
    UPDATE inventoryProduct
    SET quantity = quantity + @Quantity
    WHERE "productId" = @ProductId
    COMMIT
END