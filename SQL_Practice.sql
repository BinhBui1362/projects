/*
REFERENCE: "SQL Practice Problems: 57 beginning, intermediate, and advanced challenges 
for you to solve using a glearn-by-doingh approach" by Sylvia Moestl Vasilik
*/


--#1 Get information about late order of al employees
with SumOrders as (
select EmployeeID, COUNT(OrderID) as TotalSumOrders
from Orders 
group by EmployeeID), 
LateOrders as (
select EmployeeID, COUNT(OrderID) as TotalLateOrders
from Orders 
where ShippedDate > RequiredDate
group by EmployeeID),
AverageLate as (
select EmployeeID, AVG(datediff(DAY,RequiredDate,ShippedDate)) as AvgLate
from Orders
where ShippedDate > RequiredDate
group by EmployeeID)
select e.EmployeeID, e.LastName, s_ord.TotalSumOrders, l_ord.TotalLateOrders,
cast((l_ord.TotalLateOrders * 1.00)/(s_ord.TotalSumOrders)as decimal(10,2)) as LatePercentage, AvgLate
from Employees e join SumOrders s_ord on e.EmployeeID=s_ord.EmployeeID
left join LateOrders l_ord on s_ord.EmployeeID = l_ord.EmployeeID
left join AverageLate on AverageLate.EmployeeID = l_ord.EmployeeID



--#2 Customer classification
with PurchaseInfo as (
Select Customers.CustomerID ,Customers.CompanyName, 
SUM(Quantity * UnitPrice) as TotalOrderAmount
From Customers join Orders on Orders.CustomerID =
Customers.CustomerID
join OrderDetails on Orders.OrderID = OrderDetails.OrderID
Where OrderDate between '19960101' and '19970101'
Group By Customers.CustomerID,Customers.CompanyName),
CustomerClassification as (
Select CustomerID, CompanyName ,TotalOrderAmount,
case 
when TotalOrderAmount >= 0 and TotalOrderAmount < 1000 then 'Low'
when TotalOrderAmount >= 1000 and TotalOrderAmount < 5000 then 'Medium'
when TotalOrderAmount >= 5000 and TotalOrderAmount <10000 then 'High'
when TotalOrderAmount >= 10000 then 'Very High'
end as CustomerGroup
from PurchaseInfo)
Select CustomerGroup, Count(*) as TotalInGroup,
Count(*) * 1.0/ (select count(*) from CustomerClassification) as PercentageInGroup
from CustomerClassification
group by CustomerGroup 
order by TotalInGroup desc



--#3 Total Suppliers and Total Customers by Countries
With SupplierCountries as (
Select Country , Count(*) as Total
from Suppliers
group by Country),
CustomerCountries as (
Select Country , Count(*) as Total
from Customers 
group by Country) 
Select isnull(SupplierCountries.Country, CustomerCountries.Country) as Country, 
isnull(SupplierCountries.Total,0) as TotalSuppliers,
isnull(CustomerCountries.Total,0) as TotalCustomers
From SupplierCountries 
Full Outer Join CustomerCountries 
on CustomerCountries.Country = SupplierCountries.Country


--#4 
With NextOrderDate as (
Select CustomerID, convert(date, OrderDate) as  OrderDate,
convert(date ,Lead(OrderDate,1) 
OVER (Partition by CustomerID 
order by CustomerID, OrderDate)) as NextOrderDate
From Orders) 
Select CustomerID,OrderDate, NextOrderDate, 
DateDiff (dd, OrderDate, NextOrderDate) as DaysBetweenOrders 
From NextOrderDate 
Where DateDiff (dd, OrderDate,NextOrderDate) <= 5