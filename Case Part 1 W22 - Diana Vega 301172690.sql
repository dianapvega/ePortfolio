
/*Set Time Zone*/

set time_zone='-4:00';

select now();

/*Preliminary Data Collection
select * to investigate your tables.*/
select * from ba710case.ba710_prod;
select * from ba710case.ba710_sales;
select * from ba710case.ba710_emails;

/*Investigate production dates and prices from the prod table*/
select * from ba710case.ba710_prod
   where product_type='scooter'
   order by base_msrp;

/***PRELIMINARY ANALYSIS***/

/*Create a new table in WORK that is a subset of the prod table
which only contains scooters.
Result should have 7 records.*/
create table work.case_scoot_names as 
   select * from ba710case.ba710_prod
   where product_type = 'scooter';
   
select * from work.case_scoot_names;

/*Use a join to combine the table above with the sales information*/
create table work.case_scoot_sales as
   select a.model, a.product_type, a.product_id,
		  b.customer_id, b.sales_transaction_date, 
          date(b.sales_transaction_date) as sales_date,
          b.sales_amount, b.channel, b.dealership_id
   from work.case_scoot_names a
   inner join ba710case.ba710_sales b
      on a.product_id=b.product_id;
      
select * from work.case_scoot_sales;

/*Create a list partition for the case_scoot_sales table on product_id. (Hint: Alter table)  
Create one partition for each product_type.
Name each partition as the product's name.*/

alter table work.case_scoot_sales
   partition by list(product_id)
   (partition Lemon_2010 values in (1),
	partition Lemon_Limited_Edition values in (2),
    partition Lemon_2013 values in (3),
    partition Blade values in (5),
    partition Bat values in (7),
	partition Bat_Limited_Edition values in (8),
    partition Lemon_Zester values in (12));
      
/***PART 1: INVESTIGATE BAT SALES TRENDS***/  

/*Select Bat models from your table.*/
select * from work.case_scoot_sales partition(bat);

/*Count the number of Bat sales from your table.*/
select count(*) from work.case_scoot_sales partition(bat);

/*What is the total revenue of Bat sales?*/
select sum(sales_amount) from work.case_scoot_sales partition(bat);

/*When was most recent Bat sale?*/
select max(sales_date) from work.case_scoot_sales partition(bat);

/*Now create a table of daily sales.
Summarize of count of sales and sum of sales amount by date and product id 
(one record for each date & product id combination).
Include model, product_id, sale_date and a column for total sales for each day*/

create table work.case_daily_sales as 
select model, product_id, sales_date, count(sales_date), round(sum(sales_amount),2) as total_daily_sales
from work.case_scoot_sales
group by sales_date, product_id;

select * from work.case_daily_sales;

/*Now quantify the sales drop*/
/*Create a table of cumulative sales figures for just the Bat scooter from
the daily sales table you created.
Using the table created above, add a column that contains the cumulative
sales amount (one row per date).
Hint: Window Functions, Over*/

create table work.case_cum_sales as
select *, round(sum(total_daily_Sales) OVER(order by sales_date),2) as cumulative_sales  
from work.case_daily_sales
where model="bat";

select * from work.case_cum_sales;

/*Compute the cumulative sales for the previous week for just the Bat scooter. 
(i.e., running total of sales for previous week.)
This is calculated as the 7 day lag of cumulative sum of sales
(i.e., each record should contain the sum of sales for the current date plus
the sales for the preceeding 6 records).

When the Word document is released with PART 2, paste a sample of your 
Results Grid to the Word document.*/

create table work.case_cum_sales_week as
select *, round(sum(total_daily_Sales) OVER(rows between 6 preceding and current row),2) as cum_sales_week
from work.case_cum_sales
where model="bat";

select * from work.case_cum_sales_week;

/*Calculate the week over week sales growth as a percentage change of cumulative 
weekly sales (current record) compared to the cumulative weekly sales from the 
previous week (seven records above).

When the Word document is released with PART 2, paste a sample of your 
Results Grid to the Word document.*/

select *, round((cum_sales_week / lag(cumulative_sales, 7) OVER ()) * 100, 2) as growth_sales
from work.case_cum_sales_week;

/*Question: On what date does the cumulative weekly sales growth drop below 10%?
Answer: Cumulative weekly sales growth drop below 10% on December 06 2016.           

Question: How many days since the launch date did it take for cumulative sales growth
to drop below 10%?
Answer: 57 days                               */

/*********************************************************************************************
Is the launch timing (October) a potential cause for the drop?
Replicate the Bat sales cumulative analysis for the Bat Limited Edition.
As above, create a cumulative sales table, compute sum of sales for the previous week,
and calculate the sales growth for the past week.*/
/*Compute a cumulative sum of sales with one row per date*/

create table work.case_cum_sales_batlimed as
select *, round(sum(total_daily_Sales) OVER(order by sales_date),2) as cumulative_sales  
from work.case_daily_sales
where model="bat limited edition";

select * from work.case_cum_sales_batlimed;

/*Compute a 7 day lag of cumulative sum of sales*/

create table work.case_cum_sales_week_batlimed as
select *, round(sum(total_daily_Sales) OVER(rows between 6 preceding and current row),2) as cum_sales_week
from work.case_cum_sales_batlimed
where model="bat limited edition";

select * from work.case_cum_sales_week_batlimed;
  
/*Calculate a running sales growth as a percentage by comparing the
current sales to sales from 1 week prior*/

select *, round((cum_sales_week / lag(cumulative_sales, 7) OVER ()) * 100, 2) as growth_sales
from work.case_cum_sales_week_batlimed;

/*Question: On what date does the cumulative weekly sales growth drop below 10%?
Answer: April 29, 2017           

Question: How many days since the launch date did it take for cumulative sales growth
to drop below 10%?
Answer: 73 days                               

Question: Is there a difference in the behavior in cumulative sales growth 
between the Bat edition and either the Bat Limited edition? (Make a statement comparing
the growth statistics.)
Answer: The overall behavior in cumulative sales growth looks to be similar as they start in a 3 digit growth and decrease till almost 0 
over the time. The difference between both models is that bat drops below 10% 57 days after the launch while bat limited edition drops 73 
days after. We can say that launch timing October may be a cause for the drop but we have not enough evidence yet.          */

/*********************************************************************************************
However, the Bat Limited was at a higher price point.
Let's take a look at the 2013 Lemon model, since it's a similar price point.  
Is the launch timing (October) a potential cause for the drop?
Replicate the Bat sales cumulative analysis for the 2013 Lemon model.
As above, create a cumulative sales table, compute sum of sales for the previous week,
and calculate the sales growth for the past week.*/
/*Compute a cumulative sum of sales with one row per date*/

create table work.case_cum_sales_lemon2013 as
select *, round(sum(total_daily_Sales) OVER(order by sales_date),2) as cumulative_sales  
from work.case_daily_sales
where product_id="3";

select * from work.case_cum_sales_lemon2013;

/*Compute a 7 day lag of cumulative sum of sales*/

create table work.case_cum_sales_week_lemon2013 as
select *, round(sum(total_daily_Sales) OVER(rows between 6 preceding and current row),2) as cum_sales_week
from work.case_cum_sales_lemon2013
where product_id="3";

select * from work.case_cum_sales_week_lemon2013;

/*Calculate a running sales growth as a percentage by comparing the
current sales to sales from 1 week prior*/

select *, round((cum_sales_week / lag(cumulative_sales, 7) OVER ()) * 100, 2) as growth_sales
from work.case_cum_sales_week_lemon2013;

/*Question: On what date does the cumulative weekly sales growth drop below 10%?
Answer: July 01, 2013           

Question: How many days since the launch date did it take for cumulative sales growth
to drop below 10%?
Answer: 61 days                               

Question: Is there a difference in the behavior in cumulative sales growth 
between the Bat edition and the 2013 Lemon edition?  (Make a statement comparing
the growth statistics.)
Answer: As the last comparison, the overall behavior in cumulative sales growth looks to be similar as they start in a 3 digit growth 
and decrease till almost 0 over the time. The difference between both models is that bat drops below 10% 57 days after the launch while 
the lemon 2013 edition drops 61 days after.  
The price point is lower in lemon 2013 edition than bat edition and the launch time is also different; however, the drop in sales growth is
only 4 days later. There is no evidence to conclude that launch timing October may be a cause for the drop nor the price point.      */

  