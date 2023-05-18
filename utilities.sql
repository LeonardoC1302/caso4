-- Ejecutar el script para resetear los datos en las tablas que afecta el sp de Ventas
truncate table sales
truncate table inventoryProduct
INSERT INTO inventoryProduct (posttime, quantity, productId, operationTypeId)
VALUES ('2023-05-01 10:00:00', 50, 1, 1),
       ('2023-05-02 12:00:00', 30, 2, 1),
       ('2023-05-03 15:30:00', 40, 3, 1),
       ('2023-05-04 09:15:00', 20, 4, 1),
       ('2023-05-05 14:45:00', 60, 5, 1),
       ('2023-05-06 11:30:00', 25, 6, 1),
       ('2023-05-07 13:20:00', 35, 7, 1),
       ('2023-05-08 16:10:00', 45, 8, 1),
       ('2023-05-09 09:45:00', 55, 9, 1),
       ('2023-05-10 12:30:00', 50, 10, 1);

