/*Set Time Zone*/

set time_zone='-4:00';

select now();

/***PART 2: MARKETING ANALYSIS***/

/*General Email & Sales Prep*/

/*Create a table called WORK.CASE_SALES_EMAIL that contains all of the email data
as well as both the sales_transaction_date and the product_id from sales.
Please use the WORK.CASE_SCOOT_SALES table to capture the sales information.*/

create table WORK.CASE_SALES_EMAIL as
select e.*, s.sales_transaction_date, s.product_id
from ba710case.ba710_emails e
inner join WORK.CASE_SCOOT_SALES s
where e.customer_id=s.customer_id;

select * from WORK.CASE_SALES_EMAIL;

/*Create two separate indexes for product_id and sent_date on the newly created
   WORK.CASE_SALES_EMAIL table.*/
 
create index idx_productid on work.case_sales_email (product_id);
create index idx_sentdate on work.case_sales_email (sent_date);

/***Product email analysis****/
/*Bat emails 30 days prior to purchase
   Create a view of the previous table that:
   - contains only emails for the Bat scooter
   - contains only emails sent 30 days prior to the purchase date*/

create view work.email30d as
select * from work.case_sales_email
where datediff(sales_transaction_date, sent_date) between 0 and 30 and product_id=7;

select * from work.email30d;

/*Filter emails*/
/*There appear to be a number of general promotional emails not 
specifically related to the Bat scooter.  Create a new view from the 
view created above that removes emails that have the following text
in their subject.

Remove emails containing:
Black Friday
25% off all EVs
It's a Christmas Miracle!
A New Year, And Some New EVs*/

create view work.emailfiltered30d as
select * from work.email30d
where email_subject not like "%Black Friday%"
and email_subject not like "%25% off all EVs%"
and email_subject not like "%It's a Christmas Miracle!%"
and email_subject not like "%A New Year, And Some New EVs%";

select * from work.emailfiltered30d;

/*Question: How many rows are left in the relevant emails view.*/
/*Code:*/

select * from work.emailfiltered30d;

/*Answer: 419           */

/*Question: How many emails were opened (opened='t')?*/
/*Code:*/

select count(*) from work.emailfiltered30d
where opened="t";

/*Answer: 105           */

/*Question: What percentage of relevant emails (the view above) are opened?*/
/*Code:*/

select (select count(*) from work.emailfiltered30d
where opened="t") / count(*) * 100
from work.emailfiltered30d;

/*Answer: 25.05%            */ 

/***Purchase email analysis***/
/*Question: How many distinct customers made a purchase (CASE_SCOOT_SALES)?*/
/*Code:*/

select count(distinct customer_id) 
from work.case_scoot_sales
where product_id = "7";

/*Answer: 6,659            */

/*Question: What is the percentage of distinct customers made a purchase after 
    receiving an email?*/
/*Code:*/

select (select count(distinct customer_id)
from work.case_sales_email
where sales_transaction_date > sent_date and product_id = "7") /
count(distinct customer_id) * 100
from work.case_scoot_sales;

/*Answer: 15.09%            */
               
/*Question: What is the percentage of distinct customers that made a purchase 
    after opening an email?*/
/*Code:*/

select (select count(distinct customer_id)
from work.case_sales_email
where sales_transaction_date > opened_date and product_id = "7") /
count(distinct customer_id) * 100
from work.case_scoot_sales;
           
/*Answer: 9.53%            */

/*****LEMON 2013*****/
/*Complete a comparitive analysis for the Lemon 2013 scooter.  
Irrelevant/general subjects are:
25% off all EVs
Like a Bat out of Heaven
Save the Planet
An Electric Car
We cut you a deal
Black Friday. Green Cars.
Zoom 
 
/***Product email analysis****/
/*Lemon emails 30 days prior to purchase
   Create a view that:
   - contains only emails for the Lemon 2013 scooter
   - contains only emails sent 30 days prior to the purchase date*/

create view work.lemonemail30d as
select * from work.case_sales_email
where datediff(sales_transaction_date, sent_date) between 0 and 30 and product_id=3;

select * from work.lemonemail30d;

/*Filter emails*/
/*There appear to be a number of general promotional emails not 
specifically related to the Lemon scooter.  Create a new view from the 
view created above that removes emails that have the following text
in their subject.

Remove emails containing:
25% off all EVs
Like a Bat out of Heaven
Save the Planet
An Electric Car
We cut you a deal
Black Friday. Green Cars.
Zoom */

create view work.lemonemailfiltered30d as
select * from work.lemonemail30d
where email_subject not like "%25% off all EVs%"
and email_subject not like "%Like a Bat out of Heaven%"
and email_subject not like "%Save the Planet%"
and email_subject not like "%An Electric Car%"
and email_subject not like "%We cut you a deal%"
and email_subject not like "%Black Friday. Green Cars%"
and email_subject not like "%Zoom%";

select * from work.lemonemailfiltered30d;

/*Question: How many rows are left in the relevant emails view.*/
/*Code:*/

select * from work.lemonemailfiltered30d;

/*Answer: 529           */

/*Question: How many emails were opened (opened='t')?*/
/*Code:*/

select count(*) from work.lemonemailfiltered30d
where opened="t";

/*Answer: 133           */

/*Question: What percentage of relevant emails (the view above) are opened?*/
/*Code:*/

select (select count(*) from work.lemonemailfiltered30d
where opened="t") / count(*) * 100
from work.lemonemailfiltered30d;

/*Answer: 25.14%            */ 

/***Purchase email analysis***/
/*Question: How many distinct customers made a purchase (CASE_SCOOT_SALES)?*/
/*Code:*/

select count(distinct customer_id) 
from work.case_scoot_sales
where product_id = "3";

/*Answer: 13,854            */

/*Question: What is the percentage of distinct customers made a purchase after 
    receiving an email?*/
/*Code:*/

select (select count(distinct customer_id)
from work.case_sales_email
where sales_transaction_date > sent_date and product_id = "3") /
count(distinct customer_id) * 100
from work.case_scoot_sales;

/*Answer: 26.17%            */
               
/*Question: What is the percentage of distinct customers that made a purchase 
    after opening an email?*/
/*Code:*/

select (select count(distinct customer_id)
from work.case_sales_email
where sales_transaction_date > opened_date and product_id = "3") /
count(distinct customer_id) * 100
from work.case_scoot_sales;

/*Answer: 14.84%            */
