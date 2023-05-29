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
