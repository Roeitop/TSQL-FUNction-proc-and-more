--0.1
declare @FullName varchar(50), @HiringDate datetime

select @FullName = LastName + ' ' + FirstName,
	   @HiringDate = HireDate
from Employees
where EmployeeID = 1;

print 'Employee name is ' + @FullName + 
	  ', hiring date = ' + convert(varchar(50), @HiringDate, 3)

select * 
from Employees;

--0.2
select EmployeeID,
	   LastName + ' ' + FirstName as FullName,
	   IsEven = 
	   case
		when EmployeeID % 2 = 0 then 'Yes'
		else 'No'
	   end
from Employees;

select EmployeeID,
	   LastName + ' ' + FirstName as FullName,
	   IsEven = 
	   case EmployeeID % 2
		when 0 then 'Yes'
		else 'No'
	   end
from Employees;

select EmployeeID,
	   LastName + ' ' + FirstName as FullName,
	   iif(EmployeeID % 2 = 0, 'Yes', 'No') as IsEven
from Employees;

--1
declare @message varchar(40) = 'The date today is: ',
		@curDate datetime = getdate()
print @message + convert(varchar(50), @curDate, 3)

--2
declare @lastName varchar(40)
set @lastName = (
	select LastName
	from Employees
	where EmployeeID = 4
)
print @lastName

--3
declare @productName nvarchar(40), @categoryName nvarchar(15)

select @productName = ProductName,
	   @categoryName = CategoryName
from Products p
inner join Categories c
on p.CategoryID = c.CategoryID
where ProductID = 5;

print @productName 
print @categoryName

--4
declare @price money

set @price = (select UnitPrice
			  from Products
			  where ProductID = 9)

if @price > 50
	print 'I like'
else
	print 'I dislike'

set @price = (select UnitPrice
			  from Products
			  where ProductID = 17)

if @price > 50
	print 'I like'
else
	print 'I dislike'

--5
select ProductName,
	   UnitPrice,
	   UpdatedPrice = 
	   case
		when UnitPrice <= 20 then UnitPrice * 1.1
		when UnitPrice between 21 and 40 then UnitPrice + 5
		else UnitPrice * 0.95
	   end
from Products;

--6
select * 
from Employees;

declare @results varchar(500)

select @results = coalesce(@results + ', ', '') +  LastName + ' ' + FirstName
from Employees

print @results

--7
go
create function is_prime (
	@num int
)
returns char(4) as
begin
	declare @i int = 2

	if @num < @i
		return 'No'

	while @i < @num
	begin
		if @num % @i = 0
			return 'No'
		set @i = @i + 1
	end
	return 'Yes'
end
go

select EmployeeID,
	   LastName + ' ' + FirstName as FullName,
	   dbo.is_prime(EmployeeID) as IsPrime
from Employees;

drop function dbo.is_prime;

--8
declare @area nchar(50) = 'Mercaz'

IF not exists (
	select 1
	from Region
	where RegionDescription = @area)
BEGIN
	declare @id int = (
		select max(RegionID) + 1
		from Region
	)
    insert into Region
	values (@id, @area);
END

select *
from Region;

--9
select om.EmployeeID, 
	   o.OrderID,
	   om.MaxDate
from Orders o
Inner join (
	select EmployeeID, 
		   max(OrderDate) as MaxDate
	from Orders
	group by EmployeeID
) om
on o.OrderDate = om.MaxDate
and o.EmployeeID = om.EmployeeID;

--10
select om.EmployeeID, 
	   om.MaxDate,
	   od.*
from Orders o
Inner join (
	select EmployeeID, 
		   max(OrderDate) as MaxDate
	from Orders
	group by EmployeeID
) om
on o.OrderDate = om.MaxDate
and o.EmployeeID = om.EmployeeID
inner join [Order Details] od
on o.OrderID = od.OrderID;

--longer
select os.EmployeeID, 
	   os.MaxDate,
	   od.*
from [Order Details] od
inner join (
	select om.EmployeeID, 
		   o.OrderID,
		   om.MaxDate
	from Orders o
	Inner join (
		select EmployeeID, 
			   max(OrderDate) as MaxDate
		from Orders
		group by EmployeeID
	) om
	on o.OrderDate = om.MaxDate
	and o.EmployeeID = om.EmployeeID
) os
on os.OrderID = od.OrderID;

--11
with OrderMax as
(
	select EmployeeID, 
		   max(OrderDate) as MaxDate
	from Orders
	group by EmployeeID
)
select om.EmployeeID, 
	   om.MaxDate,
	   od.*
from Orders o
Inner join OrderMax om
on o.OrderDate = om.MaxDate
and o.EmployeeID = om.EmployeeID
inner join [Order Details] od
on o.OrderID = od.OrderID;

--longer
with OrderMax as
(
	select EmployeeID, 
		   max(OrderDate) as MaxDate
	from Orders
	group by EmployeeID
), OrderMaxEmp as
(
	select om.EmployeeID, 
		   o.OrderID,
		   om.MaxDate
	from Orders o
	inner join OrderMax om
	on o.OrderDate = om.MaxDate
	and o.EmployeeID = om.EmployeeID
)
select os.EmployeeID, 
	   os.MaxDate,
	   od.*
from [Order Details] od
inner join OrderMaxEmp os
on od.OrderID = os.OrderID;

--12
go
create view vw_old_employyes
as 
select *
from Employees
where datediff(yy, BirthDate, getdate()) > 60;
go

--13
select *
from Orders
where EmployeeID in (
	select EmployeeID
	from vw_old_employyes);

--14
go
create view vw_company_total_orders
as
select c.CompanyName,
	   sum(o.OrderID) as TotalOrders
from Customers c
left join Orders o
on c.CustomerID = o.CustomerID
group by c.CompanyName;
go

--15
select * 
from Customers
where CompanyName in (
	select CompanyName
	from vw_company_total_orders
	where TotalOrders > 10);

--16
go
create view vw_order_details_names
as
select od.OrderID,
	   od.UnitPrice,
	   od.Quantity,
	   od.Discount,
	   p.ProductName
from [Order Details] od
left join Products p
on od.ProductID = p.ProductID;
go

select *
from vw_order_details_names;

--17
/*
select *
from Orders
*/

select *
from Orders
where OrderID in (
	select top(10) OrderID
	from vw_order_details_names
	group by OrderID
	order by sum(UnitPrice * Quantity * (1 - Discount)) desc)

--18

--19
select p.ProductID,
	   p.ProductName,
	   od.TotalUnits
from Products p
inner join (
	select top(1) ProductID,
				  sum(Quantity) as TotalUnits
	from [Order Details]
	group by ProductID
	order by TotalUnits desc
) od
on p.ProductID = od.ProductID;


--CURSOR
--1
select *
from Employees;

set nocount on;
declare @Result varchar(500)

declare @FullName nvarchar(30)
declare C cursor fast_forward
for
select LastName + ' ' +
	   FirstName as Fullname
from Employees;

open C;
fetch next from C into @FullName;

while @@FETCH_STATUS = 0
begin
	if @Result is null
		set @Result = @FullName
	else 
		set @Result += ', ' + @FullName

	fetch next from C into @FullName;
end
close C;
deallocate C;

print @Result;

--2
set nocount on;
declare @Result2 table
(
	EmployeeID int,
	FullName nvarchar(30),
	Age int,
	AgeDiff int
);

declare @EmployeeID int, 
		@FullName2 nvarchar(30),
		@Age int,
		@AgeDiff int,
		@NextAge int

declare C cursor fast_forward
for
select EmployeeID, 
	   LastName + ' ' + FirstName as Fullname,
	   datediff(yy, BirthDate, getdate()) as Age
from Employees
order by EmployeeID;

open C;
fetch next from C into @EmployeeID, 
					   @FullName2,
					   @Age;

while @@FETCH_STATUS = 0
begin
	set @NextAge = (
		select datediff(yy, BirthDate, getdate()) as Age
		from Employees
		where EmployeeID = @EmployeeID + 1);

	set @AgeDiff = abs(@Age - @NextAge)

	insert into @Result2
	values(@EmployeeID, @FullName2, @Age, @AgeDiff);

	fetch next from C into @EmployeeID, 
						   @FullName2,
						   @Age;
end
close C;
deallocate C;

select *
from @Result2;


--Class Exercise
begin try
	begin transaction
		insert into Region
		values (3, 'new');

		insert into Orders
		(EmployeeID, OrderDate)
		values (2, GETDATE());
	commit
end try
begin catch
	raiserror('Oopsy :(', 10, 1)
	rollback
end catch

select *
from Region;

select * 
from Orders;

--Class Exercise Function
go
create function count_workers (
	@EmployeeID int
)
returns int as
begin
	declare @result int;
	set @result = (
		select count(EmployeeID)
		from Employees 
		where ReportsTo = @EmployeeID
	);
	return coalesce(@result, 0)
end
go

print dbo.count_workers(2);

select *
from Employees;


--UDF--
--1
go
create function find_oldest ()
returns int as
begin
	declare @result int;
	set @result = (
		select top(1) EmployeeID
		from Employees 
		where BirthDate is not null
		Order by BirthDate);

	return @result
end
go

select *
from Employees
where EmployeeID = dbo.find_oldest();

drop function dbo.find_oldest;

--2
go
create function return_price (
	@OrderID int
)
returns money as
begin
	declare @result money;
	set @result = (
		select sum(UnitPrice * Quantity * (1 - Discount)) as TSum
		from [Order Details]
		where OrderID = @OrderID);

	return @result
end
go

select OrderID,
	   OrderDate,
	   dbo.return_price(OrderID) as TotalSum
	   from Orders;

--3
go
create function return_full_name (
	@EmployeeID int
)
returns varchar(40) as
begin
	declare @result varchar(40);
	set @result = (
		select FirstName + ' ' + LastName as FullName
		from Employees
		where EmployeeID = @EmployeeID);

	return @result
end
go

select EmployeeID,
	   dbo.return_full_name(EmployeeID) as FullName
from Employees;

drop function dbo.return_full_name;

--4
go
create function return_upper_string (
	@CustomerID nchar(5)
)
returns nchar(5) as
begin
	declare @result nchar(5);
	set @result = UPPER(LEFT(@CustomerID, 1)) + 
				  LOWER(SUBSTRING(@CustomerID, 2, LEN(@CustomerID) - 1))

	return @result
end
go

select CustomerID,
	   dbo.return_upper_string(CustomerID) as UpperStr
from Customers;

drop function dbo.return_upper_string;

--5
go
create function days_till_bday (
	@BirthDate datetime
)
returns int as
begin
	declare @new_date datetime;
	set @new_date = dateadd(yy, (year(getdate()) - year(@BirthDate)), @BirthDate) 
	
	if @new_date < GETDATE()
		set @new_date = dateadd(yy, 1, @new_date)

	return datediff(dd, getdate(), @new_date)
end
go

select FirstName + ' ' + LastName as FullName,
	   dbo.days_till_bday(BirthDate) as DaysTillBDay
from Employees;

drop function dbo.days_till_bday;

--6
go
create function is_perfect (
	@ProductID int
)
returns bit as
begin
	declare @cur_num int = 1,
			@sum int = 0

	while @cur_num < @ProductID
	begin
		if @ProductID % @cur_num = 0
			set @sum += @cur_num

		set @cur_num += 1
	end

	if @ProductID = @sum
		return 1
	return 0
end
go

select ProductID, 
	   ProductName,
	   iif(dbo.is_perfect(ProductID) = 1, 'TRUE', 'FALSE') as Perfect
from Products;

drop function dbo.is_perfect;