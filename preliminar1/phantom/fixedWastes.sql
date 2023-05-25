-- SQLBook: Code
CREATE PROCEDURE GetWasteMovementsByProducer
    @producerId INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    BEGIN TRANSACTION
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
        dbo.wasteMovements wm WITH (UPDLOCK, HOLDLOCK)
    INNER JOIN
        dbo.wastes w WITH (UPDLOCK, HOLDLOCK) ON wm.wasteId = w.wasteId
    INNER JOIN
        dbo.wasteTypes wt WITH (UPDLOCK, HOLDLOCK) ON w.wasteType = wt.wasteTypeId
    INNER JOIN
        dbo.addresses a WITH (UPDLOCK, HOLDLOCK) ON wm.addressId = a.addressId
    INNER JOIN
        dbo.countries co WITH (UPDLOCK, HOLDLOCK) ON a.countryId = co.countryId
    INNER JOIN
        dbo.containers c WITH (UPDLOCK, HOLDLOCK) ON wm.containerId = c.containerId
    INNER JOIN
        dbo.containerTypes ct WITH (UPDLOCK, HOLDLOCK) ON c.containerTypeId = ct.containerTypeId
    INNER JOIN
        dbo.producersXmovements pxm WITH (UPDLOCK, HOLDLOCK) ON wm.wasteMovementId = pxm.wasteMovementId
    INNER JOIN
        dbo.producers p WITH (UPDLOCK, HOLDLOCK) ON pxm.producerId = p.producerId
    WHERE
        p.producerId = @producerId
    ORDER BY
        wm.posttime DESC;
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
        dbo.wasteMovements wm WITH (UPDLOCK, HOLDLOCK)
    INNER JOIN
        dbo.wastes w WITH (UPDLOCK, HOLDLOCK) ON wm.wasteId = w.wasteId
    INNER JOIN
        dbo.wasteTypes wt WITH (UPDLOCK, HOLDLOCK) ON w.wasteType = wt.wasteTypeId
    INNER JOIN
        dbo.addresses a WITH (UPDLOCK, HOLDLOCK) ON wm.addressId = a.addressId
    INNER JOIN
        dbo.countries co WITH (UPDLOCK, HOLDLOCK) ON a.countryId = co.countryId
    INNER JOIN
        dbo.containers c WITH (UPDLOCK, HOLDLOCK) ON wm.containerId = c.containerId
    INNER JOIN
        dbo.containerTypes ct WITH (UPDLOCK, HOLDLOCK) ON c.containerTypeId = ct.containerTypeId
    INNER JOIN
        dbo.producersXmovements pxm WITH (UPDLOCK, HOLDLOCK) ON wm.wasteMovementId = pxm.wasteMovementId
    INNER JOIN
        dbo.producers p WITH (UPDLOCK, HOLDLOCK) ON pxm.producerId = p.producerId
    WHERE
        p.producerId = @producerId
    ORDER BY
        wm.posttime DESC;
    COMMIT
END