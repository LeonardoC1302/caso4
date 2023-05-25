-- SQLBook: Code
CREATE PROCEDURE GetWasteMovementsByProducer
    @producerId INT
AS
BEGIN
    BEGIN TRANSACTION
    -- Escenario: Phantom Read
    -- Si durante la ejecución de este stored procedure se insertan, eliminan o modifican filas en la tabla wastes,
    -- es posible que se produzcan lecturas fantasma.
    DECLARE @maxId INT;
    SELECT
        wm.posttime,
        wm.quantity,
        c.containerName,
        w.wasteName,
        wt.typeName,
        p.producerName,
        co.countryName
    FROM
        dbo.wasteMovements wm
    INNER JOIN
        dbo.wastes w ON wm.wasteId = w.wasteId
    INNER JOIN
        dbo.wasteTypes wt ON w.wasteType = wt.wasteTypeId
    INNER JOIN
        dbo.addresses a ON wm.addressId = a.addressId
    INNER JOIN
        dbo.countries co ON a.countryId = co.countryId
    INNER JOIN
        dbo.containers c ON wm.containerId = c.containerId
    INNER JOIN
        dbo.containerTypes ct ON c.containerTypeId = ct.containerTypeId
    INNER JOIN
        dbo.producersXmovements pxm ON wm.wasteMovementId = pxm.wasteMovementId
    INNER JOIN
        dbo.producers p ON pxm.producerId = p.producerId
    WHERE
        p.producerId = @producerId
    ORDER BY
        wm.posttime DESC;
    SELECT @maxId = MAX(wasteMovements.wasteMovementId) -- Se guarda la fecha máxima
    FROM dbo.wasteMovements;
    WAITFOR DELAY '00:00:010'
    SELECT
        wm.posttime,
        wm.quantity,
        c.containerName,
        w.wasteName,
        wt.typeName,
        p.producerName,
        co.countryName
    FROM
        dbo.wasteMovements wm
    INNER JOIN
        dbo.wastes w ON wm.wasteId = w.wasteId
    INNER JOIN
        dbo.wasteTypes wt ON w.wasteType = wt.wasteTypeId
    INNER JOIN
        dbo.addresses a ON wm.addressId = a.addressId
    INNER JOIN
        dbo.countries co ON a.countryId = co.countryId
    INNER JOIN
        dbo.containers c ON wm.containerId = c.containerId
    INNER JOIN
        dbo.containerTypes ct ON c.containerTypeId = ct.containerTypeId
    INNER JOIN
        dbo.producersXmovements pxm ON wm.wasteMovementId = pxm.wasteMovementId
    INNER JOIN
        dbo.producers p ON pxm.producerId = p.producerId
    WHERE
        p.producerId = @producerId AND wm.wasteMovementId <= @maxId -- Se filtra por la fecha máxima
    ORDER BY
        wm.posttime DESC;
    COMMIT
END