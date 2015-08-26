/*by Kyaw Min Htin (Jon Htin)
khtin@student.unimelb.edu.au for queries*/

--2. Find the names of brown items sold by the Recreation department.
Select * FROM Department NATURAL JOIN Sale NATURAL JOIN Item
WHERE DepartmentName = 'Recreation' AND ItemColour = 'Brown';

--3. Of those items delivered, find the items not delivered to the Books department. 
Select * FROM Department NATURAL JOIN Delivery
WHERE DepartmentName Not Like 'Books';

--4. Find the departments that have never sold a geo positioning system
--THIS DOESN’T WORK:
/*
Select DepartmentName, COUNT(*) FROM Department NATURAL JOIN Sale NATURAL JOIN Item
WHERE ItemName = 'Geo positioning system'
Group By DepartmentID
HAVING COUNT(*)=0;
*/
--Only the departments that have sold it are in the table so nothing appears.

--This does tho:
SELECT DepartmentName FROM Department
WHERE DepartmentID NOT IN
	(SELECT DepartmentID FROM Sale NATURAL JOIN Item
	WHERE ItemName = "Geo Positioning System"); 

--5. Find the departments that have sold compasses and at least six other items.
SELECT DepartmentID, DepartmentName FROM Department NATURAL JOIN Sale NATURAL JOIN Item
WHERE DepartmentID IN
(SELECT DepartmentID FROM Sale
	GROUP BY DepartmentID
	HAVING COUNT(DISTINCT ItemID)>5)
AND ItemName LIKE 'Compass';

--6. Find the departments that sell at least 4 items. 
---(Alternative wording: Find the department/s that sell at least 4 different items.)
SELECT DepartmentID, DepartmentName FROM Sale NATURAL JOIN Department
GROUP BY DepartmentID
HAVING COUNT(DISTINCT ItemID)>3

--7. Find the departments that sell at least 4 items and list how many items each department sells 
--(Alternative wording: Find the departments that have made 4 or more transactions and 
--list how many transactions each department has made.)
SELECT DepartmentID, DepartmentName, COUNT(DISTINCT ItemID) FROM Sale NATURAL JOIN Department
GROUP BY DepartmentID
HAVING COUNT(DISTINCT ItemID)>3

--8. Find the employees who are in a the same department as their manager's department.
--NOTE: SELECT F.EmployeeID, F.LastName, S.EmployeeID, S.LastName, F.Country
--FROM Employee F INNER JOIN Employee S ON F.Country = S.Country
--WHERE F.EmployeeID < S.EmployeeID
--ORDER BY F.EmployeeID, S.EmployeeID;
--^above is an example of a self join. Below is the solution:
SELECT Emp.EmployeeID, Emp.EmployeeName
FROM Employee Emp INNER JOIN Employee Boss ON Emp.BossID = Boss.EmployeeID
WHERE Emp.DepartmentID = Boss.DepartmentID;

--9. Find the employees whose salary is less than half that of their managers.
SELECT Emp.EmployeeID, Emp.EmployeeName, Emp.EmployeeSalary, Boss.EmployeeSalary
FROM Employee Emp INNER JOIN Employee Boss ON Emp.BossID = Boss.EmployeeID
WHERE Emp.EmployeeSalary < Boss.EmployeeSalary/2;

--10. Find the brown items sold by no department on the second floor. 
Select DISTINCT ItemName FROM Department NATURAL JOIN Sale NATURAL JOIN Item 
WHERE DepartmentFloor != 2 AND ItemColour = 'Brown';
--***NOTE this is wrong, it doesn't pick up if the item isn't sold by any department.
	
--11. Find items delivered by all suppliers
SELECT ItemID, ItemName FROM Item NATURAL JOIN Supplier NATURAL JOIN Delivery
GROUP BY ItemID
HAVING COUNT(DISTINCT SupplierID) =
	(SELECT COUNT(DISTINCT SupplierID) FROM Supplier);

--12.  Find the items delivered by at least two suppliers.
SELECT ItemID, ItemName FROM Item NATURAL JOIN Supplier NATURAL JOIN Delivery
GROUP BY ItemID
HAVING COUNT(DISTINCT SupplierID) >= 2;

--13. Find the items not delivered by Nepalese Corp 
--(Alternative wording: Find any items that have never been delivered by Nepalese Corp.)
SELECT ItemName From Item
WHERE ItemID NOT IN
	(SELECT ItemID FROM Item NATURAL JOIN Supplier NATURAL JOIN Delivery
		WHERE SupplierName LIKE 'Nepalese Corp.');

--14. Find the items sold by at least two departments. 
Select DISTINCT ItemName FROM Department NATURAL JOIN Sale NATURAL JOIN Item 
GROUP BY ItemID
HAVING COUNT(DepartmentID)>=2;

--15. Find the items delivered for which there have been no sales.
SELECT DISTINCT ItemName FROM Delivery NATURAL JOIN Item
WHERE ItemID NOT IN
	(Select DISTINCT ItemID FROM Sale);

--16. Find the items delivered to all departments except Administration departments (Management, Marketing, Personnel, Accounting, Purchasing). 
/*VERSION 2*/
SELECT ItemID, ItemName FROM Item NATURAL JOIN Delivery NATURAL JOIN Department
WHERE DepartmentName NOT IN ('Management', 'Marketing', 'Personnel',  
								'Accounting', 'Purchasing')
GROUP BY ItemID
HAVING COUNT(DISTINCT DepartmentID) IN
	(SELECT COUNT(DISTINCT DepartmentID) FROM Department
		WHERE DepartmentName NOT IN ('Management', 'Marketing', 'Personnel',  
								'Accounting', 'Purchasing')
	);

--17. Find the name of the highest-paid employee in the Marketing department.
SELECT EmployeeName, MAX(EmployeeSalary) FROM Employee INNER JOIN Department
WHERE DepartmentName = 'Marketing';

--18. Find the names of employees who make 40 per cent less than the average salary. 
SELECT EmployeeName FROM Employee
WHERE EmployeeSalary <= (SELECT AVG(EmployeeSalary)*0.60 FROM Employee)

--19. Find the names of employees with a salary greater than the minimum salary paid to a manager.
SELECT EmployeeName FROM Employee
WHERE EmployeeSalary > (
	SELECT MIN(EmployeeSalary) FROM Employee
	WHERE EmployeeID IN (SELECT Distinct BossID FROM Employee)
    );

--20. Find the names of suppliers that do not supply compasses or geo positioning systems. 
SELECT SupplierName FROM Supplier 
WHERE SupplierID NOT IN (
	SELECT DISTINCT SupplierID FROM Supplier NATURAL JOIN Delivery NATURAL JOIN Item
    WHERE ItemName = 'Geopositioning system' OR ItemName = 'Compass');

--21. Find the number of employees with a salary under $15,000.
SELECT COUNT(EmployeeID) FROM Employee
WHERE EmployeeSalary < 15000;

--22. Find the number of items of type C sold by the departments on the third floor. 
SELECT COUNT(DISTINCT ItemID) FROM Item NATURAL JOIN Sale NATURAL JOIN Department
WHERE ItemType = 'C' AND DepartmentFloor = 3;

--23. Find the number of units sold of each item.
SELECT ItemName, SUM(SaleQTY) AS SaleTotal FROM Item NATURAL JOIN Sale
GROUP BY ItemID;

--24. Find the khaki items delivered by all suppliers.
/* Uses HAVING instead of nesting query in where
-Kyaw Min Htin (Jon Htin)*/

SELECT ItemName FROM Supplier NATURAL JOIN Delivery NATURAL JOIN Item
WHERE ItemColour = 'Khaki'
GROUP BY ItemID
HAVING COUNT(DISTINCT SupplierID) IN (SELECT COUNT(SupplierID) FROM Supplier);


--25. Find any suppliers that deliver no more than two unique items. List the suppliers in alphabetical order.
SELECT SupplierName, COUNT(DISTINCT ItemID) FROM Supplier NATURAL JOIN Delivery
GROUP BY SupplierID
HAVING COUNT(DISTINCT ItemID) <= 2
ORDER BY SupplierName;

--26. Find the suppliers that deliver to all departments. 
-- Don't forget to exclude the administrative departments, which don't sell items. 
/* WHERE statement added so that suppliers that only deliveries to non-admin
departments are counted */

SELECT SupplierName FROM Supplier NATURAL JOIN Delivery NATURAL JOIN Department
WHERE DepartmentName NOT IN ('Management', 'Marketing', 'Personnel',  
								'Accounting', 'Purchasing')
GROUP BY SupplierID
HAVING COUNT(DISTINCT DepartmentID) IN
	(SELECT COUNT(DISTINCT DepartmentID) FROM Department
		WHERE DepartmentName NOT IN ('Management', 'Marketing', 'Personnel',  
								'Accounting', 'Purchasing')
	);

--27. Find the names of suppliers that have never delivered a compass. 
SELECT SupplierName FROM Supplier
WHERE SupplierID NOT IN
	(SELECT SupplierID FROM Delivery NATURAL JOIN Item
	WHERE ItemName = 'Compass');

--28. Find, for each department, its floor and the average salary in the department. 
SELECT DepartmentName, DepartmentFloor, AVG(EmployeeSalary) FROM Department NATURAL JOIN Employee
GROUP BY DepartmentID;

--29 If Nancy's boss has a boss, who is it?
SELECT Superboss.EmployeeName FROM Employee Emp INNER JOIN Employee Boss ON Emp.BossID = Boss.EmployeeID
    INNER JOIN Employee Superboss ON Boss.BossID = Superboss.EmployeeID
	WHERE Emp.EmployeeName = 'Nancy'

--30 List each employee and the difference between his or her salary and the average salary of his or her department. 
CREATE VIEW DepAvgsal(DepartmentID, DepAvgsal) AS
	SELECT DepartmentID, AVG(EmployeeSalary) AS DepAvgSal FROM Department NATURAL JOIN Employee
    GROUP BY DepartmentID;

SELECT EmployeeName, FORMAT(EmployeeSalary-DepAvgSal, 2) AS SalDepAvgDifference
FROM Employee NATURAL JOIN DepAvgsal;

--31. List the departments on the second floor that contain more than one employee.
SELECT DepartmentName FROM Department NATURAL JOIN Employee
WHERE DepartmentFloor = 2
GROUP BY DepartmentID
HAVING COUNT(EmployeeID)>1;

--32. List the departments on the second floor. 
SELECT DepartmentName FROM Department
WHERE DepartmentFloor = 2;

--33. List the names of employees who earn more than the average salary of employees 
--in the Accounting department.
SELECT EmployeeName FROM Employee
WHERE EmployeeSalary > (
	SELECT AVG(EmployeeSalary) FROM Employee NATURAL JOIN Department
	WHERE DepartmentName = 'Accounting');

--34. List the names of items delivered by each supplier. 
--Arrange the report by supplier name, and within supplier name, list the items in alphabetical order. 
SELECT SupplierName, ItemName FROM Supplier NATURAL JOIN Delivery NATURAL JOIN Item
ORDER BY SupplierName, ItemName;

--35. List the names of managers who supervise only one person.
SELECT Boss.EmployeeName, Count(Lowlvl.EmployeeID) 
FROM Employee Lowlvl INNER JOIN Employee Boss ON Lowlvl.BossID = Boss.EmployeeID
GROUP BY Lowlvl.BossID
HAVING Count(Lowlvl.EmployeeID) = 1;

--36. List the number of employees in each department.
SELECT DepartmentName, COUNT(EmployeeID) From Department NATURAL JOIN Employee
GROUP BY DepartmentID;

--37. Whom does Todd manage?
SELECT Lowlvl.EmployeeName 
FROM Employee Lowlvl INNER JOIN Employee Boss ON Lowlvl.BossID = Boss.EmployeeID
WHERE Boss.EmployeeName = 'Todd';

--38. Find the name of Sophie's Boss
SELECT Boss.EmployeeName 
FROM Employee Lowlvl INNER JOIN Employee Boss ON Lowlvl.BossID = Boss.EmployeeID
WHERE Lowlvl.EmployeeName = 'Sophie';

--39. Find the name of 
/*by Kyaw Min Htin (Jon Htin)
khtin@student.unimelb.edu.au for queries*/