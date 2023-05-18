CREATE PROCEDURE GetWasteMovementsByProducer
    @producerId INT
AS
BEGIN
    -- READ COMMITED ISOLATION LEVEL hace que el sp solo lea datos que ya han sido confirmados en la base de datos y no datos modificados por otras transacciones que aún no han sido confirmadas (uncommitted).
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

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
        -- ROWLOCK hace que se aplique un bloqueo de fila a las tablas que se están leyendo, lo cual evita cambios concurrentes en las filas que se están leyendo.
        dbo.wasteMovements wm WITH (ROWLOCK)
    INNER JOIN
        dbo.wastes w WITH (ROWLOCK) ON wm.wasteId = w.wasteId
    INNER JOIN
        dbo.wasteTypes wt WITH (ROWLOCK) ON w.wasteType = wt.wasteTypeId
    INNER JOIN
        dbo.addresses a WITH (ROWLOCK) ON wm.addressId = a.addressId
    INNER JOIN
        dbo.countries co WITH (ROWLOCK) ON a.countryId = co.countryId
    INNER JOIN
        dbo.containers c WITH (ROWLOCK) ON wm.containerId = c.containerId
    INNER JOIN
        dbo.containerTypes ct WITH (ROWLOCK) ON c.containerTypeId = ct.containerTypeId
    INNER JOIN
        dbo.producersXmovements pxm WITH (ROWLOCK) ON wm.wasteMovementId = pxm.wasteMovementId
    INNER JOIN
        dbo.producers p WITH (ROWLOCK) ON pxm.producerId = p.producerId
    WHERE
        p.producerId = @producerId
    ORDER BY
        wm.posttime DESC;
END
