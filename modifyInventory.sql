CREATE PROCEDURE updateInventory
    @productId INT,
    @quantity INT
AS
BEGIN
    BEGIN TRANSACTION;
    UPDATE inventoryProduct
    SET quantity = quantity - @quantity  -- Modify the quantity value as needed
    WHERE productId = @productId;  -- Specify the product you want to modify
    
    COMMIT;
END;
