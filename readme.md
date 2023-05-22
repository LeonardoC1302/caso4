# How can I test each problem? 
## Dirty Read
- On one query window execute 'exec UpdateProductQuantity 1, 60'
- Afterwards, execute 'exec GetProductQuantity 1' on another window
- With the original sp, you should get 110 as Quantity
- With the updated one, you should get 50 because the sp is not reading uncommitted data
- Check the files on [DirtyRead](./dirtyRead/)

## Lost update
- On one query window execute 'exec registerSales 1, 1, 1, 50.0, 1, 1, 30'
- Afterwards, execute 'exec addProduct 1, 30' on another window
- With the original sp, you should get a 20 as final quantity
- With the updated one, you should get 50 because the update is not lost
- Check the files on [LostUpdate](./lostUpdate/)

## Phantom
- On one query window execute 'exec GetWasteMovementsByProducer 1'
- Afterwards, execute 'exec InsertWasteMovement "2023-01-01 00:00:00.000", "phantom", 0, 1, 1, 1, 999.9, 1, 0, "Computer Phantom", 1, 1, 1, 1' on another query window.
- With the original sp, you should get a difference in the total registers returned.
- With the updated one, both quantities should be equal.
- Check the files on [Phantom](./phantom/)

## Deadlock
- On one query window execute 'exec moneyTransaction @senderId=1, @receiverId =2, @amount=100 
- Afterwards, execute 'exec moneyTransaction @senderId=2, @receiverId =1, @amount=100 on another query window.
- This should create a deadlock on the system
- With the updated one when you run both querys there won´t be a deadlock
- Check the files on [Deadlock](./deadlock/)