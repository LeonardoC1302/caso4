-- Used to get all the collection assignments with their corresponding city name
-- Ordered by city name

SELECT ca.*, c.CityName
FROM collectionAssignments ca
JOIN collectionPoints cp ON ca.collectionPointId = cp.collectionPointId
JOIN addresses a ON cp.addressId = a.addressId
JOIN cities c ON a.cityId = c.cityId
ORDER BY c.CityName

-- Query used to get the csv
SELECT TOP 100 *
FROM collectionAssignments
ORDER BY NEWID();


SELECT p.producerId, p.producerName, p.balance, p.industryTypeId, SUM(ca.volumen) as 'Volumen Total'
FROM producers p
JOIN collectionAssignments ca ON ca.producerId = p.producerId
GROUP BY p.producerId, p.producerName, p.balance, p.industryTypeId
ORDER BY SUM(ca.volumen);

SELECT c.collectorId, c.collectorName, c.balance, SUM(ca.volumen) as 'Volumen Total'
FROM collectors c
JOIN collectionAssignments ca ON ca.collectorId = c.collectorId
GROUP BY c.collectorId, c.collectorName, c.balance
ORDER BY SUM(ca.volumen);	

SELECT cp.pointName, c.cityName, SUM(ca.volumen) as 'Volumen Total'
FROM collectionPoints cp
JOIN addresses ad ON ad.addressId = cp.addressId
JOIN cities c ON c.cityId = ad.cityId
JOIN collectionAssignments ca on ca.collectionPointId = cp.collectionPointId
GROUP BY cp.pointName, c.cityName
ORDER BY SUM(ca.volumen)

SELECT TOP 100
ca.collectionAssignmentId, c.collectorName, p.producerName, ca.collectionDate, cp.pointName, ca.volumen
FROM collectionAssignments ca
JOIN collectors c ON c.collectorId = ca.collectorId
JOIN producers p ON p.producerId = ca.producerId
JOIN collectionPoints cp ON cp.collectionPointId = ca.collectionPointId
ORDER BY NEWID();