-- SQLBook: Code
CREATE PROCEDURE GetWasteMovementsByProducer
    @producerId INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;

    -- Escenario: Phantom Read
    -- Si durante la ejecución de este stored procedure se insertan, eliminan o modifican filas en la tabla wastes,
    -- es posible que se produzcan lecturas fantasma.
    SELECT
        wm.posttime,
        wm.quantity,
        c.containerName,
        w.wasteName,
        wt.typeName,
        p.producerName,
        co.countryName
    FROM
        dbo.wasteMovements wm WITH (HOLDLOCK) -- Acquire a shared lock on the table
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
        dbo.producersXmovements pxm WITH (HOLDLOCK) ON wm.wasteMovementId = pxm.wasteMovementId -- Acquire a shared lock on the table
    INNER JOIN
        dbo.producers p ON pxm.producerId = p.producerId
    WHERE
        p.producerId = @producerId
    ORDER BY
        wm.posttime DESC;

    COMMIT;
END;
