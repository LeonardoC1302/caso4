SELECT
	ct.countryName,
	i.industryTypeName,
	w.wasteName,
	SUM(wxc.volume) AS TotalCollected,
	SUM(p.processCost) AS TotalCost,
	SUM(p.processPrice) AS TotalCharge,
	SUM(p.processPrice - p.processCost) AS NetProfit
FROM
	collectionAssignments a
	JOIN collectionPoints cp ON a.collectionPointId = cp.collectionPointId
	JOIN addresses ad ON cp.addressId = ad.addressId
	JOIN collections c ON c.collectionAssignmentId = a.collectionAssignmentId
	JOIN wastesXcollections wxc ON wxc.collectionId = c.collectionId
	JOIN wastes w ON w.wasteId = wxc.wasteId
	JOIN processes p ON p.wasteTypeId = w.wasteType
	JOIN producers pr ON pr.producerId = a.producerId
	JOIN industryTypes i ON i.industryTypeId = pr.industryTypeId
	JOIN countries ct ON ct.countryId = ad.countryId
WHERE
	a.collectionDate BETWEEN @startDate AND @endDate AND ct.countryName = @countryName
GROUP BY
	ct.countryName,
	i.industryTypeName,
	w.wasteName
ORDER BY
	w.wasteName ASC