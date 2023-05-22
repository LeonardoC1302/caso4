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
- Check the files on [Deadlock](./deadlock/)