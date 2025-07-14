select *
from walmart_sales;

#List all unique store numbers.
select count(distinct(store)) as numbers_of_stores
from walmart_sales
;

#Find total weekly sales for Store 1.
select sum(weekly_sales) as total_sales, store
from walmart_sales
where store = 1; 

#Count how many holiday weeks there are in the dataset.
select count(Holiday_Flag) as holiday_weeks
from walmart_sales
where Holiday_Flag = 1;

#Find the average weekly sales per store.
select store, avg(weekly_sales) as Avg_sales
from walmart_sales
group by store;

#List all rows where weekly sales are greater than $2,000,000.
select *
from walmart_sales
where Weekly_Sales > 2000000;

#Calculate total sales per store for the entire dataset.
select store, sum(weekly_sales) as total_sales
from walmart_sales
group by store;

#Find the week with the highest sales overall.
select store, max(weekly_sales) as highest_sales
from walmart_sales
group by store
order by highest_sales;

#Compare average sales during holiday vs non-holiday weeks.
select Holiday_Flag, avg(weekly_sales)
from walmart_sales
group by Holiday_Flag;

#Which store had the highest sales during a holiday week?
select store, max(weekly_sales) as highest_sales, holiday_flag as holiday_week
from walmart_sales
where Holiday_Flag = 1
group by store
order by highest_sales;

#Find average temperature and fuel price by store.
select store, avg(fuel_price), avg(temperature)
from walmart_sales
group by store;

#Rank stores by their total annual sales (assume one row = one week).
create temporary table walmart_sales2
like walmart_sales;

select *
from walmart_sales2;

insert walmart_sales2
select *
from walmart_sales;

alter table walmart_sales2
add column Year int;

select *,
	substring_index(Date,'/',-1) as year
from walmart_sales2;

update walmart_sales2
set year = substring_index(Date,'/',-1);

select store, sum(weekly_sales) as Annual_sales, Year,
rank()over(partition by year order by(sum(weekly_sales))) as sales_rank
from walmart_sales2
group by year, store;

#Find the percentage increase or decrease in sales week over week per store.
select store, date, year,
lag(weekly_sales) over(order by date, store)
from walmart_sales2
;

with walmart_sales3 as (
select store, date, year, weekly_sales,
lag(weekly_sales) over(partition by store order by date) as Lag_sales
from walmart_sales2
)
select store, date, year, weekly_sales, lag_sales, round((weekly_sales-lag_sales)/nullif(lag_sales,0),2) as diff,
round(((weekly_sales-lag_sales)/nullif(lag_sales,0))*100,2) as per
from walmart_sales3;

#Identify months where average CPI was above 220
select *
from walmart_sales2;

select date, 
substring_index(substring_index(date,'/',2),'/',-1) as month
from walmart_sales2;

alter table walmart_sales2
add column Month varchar(10);

update walmart_sales2
set month = substring_index(substring_index(date,'/',2),'/',-1);

create temporary table walmart_sales4
like walmart_sales2;

insert into walmart_sales4
select *
from walmart_sales2;


update walmart_sales2
set month =
  CASE 
    WHEN month IN ('01', '1') THEN 'January'
    WHEN month IN ('02', '2') THEN 'February'
    WHEN month IN ('03', '3') THEN 'March'
    WHEN month IN ('04', '4') THEN 'April'
    WHEN month IN ('05', '5') THEN 'May'
    WHEN month IN ('06', '6') THEN 'June'
    WHEN month IN ('07', '7') THEN 'July'
    WHEN month IN ('08', '8') THEN 'August'
    WHEN month IN ('09', '9') THEN 'September'
    WHEN month = '10' THEN 'October'
    WHEN month = '11' THEN 'November'
    WHEN month = '12' THEN 'December'
  END
;

select month, round(avg(cpi),2) as Avg_CPI
from walmart_sales2
where cpi > 220
group by month;

#Group data by month and find the average sales, temperature, and fuel price
select month, 
	round(avg(weekly_sales),0) as avg_sales,
	round(avg(temperature),0) as avg_temp,
	round(avg(fuel_price),0) as avg_fuel_price
from walmart_sales2
group by month;

    






