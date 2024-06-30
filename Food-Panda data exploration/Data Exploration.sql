select * from product;
select * from users;
select * from sales;
select * from goldusers_signup;


-- Data exploration -- 

-- Q-1: What is the total amount each customer spent on Foodpanda?

select   sale.userid , sum(price) as totalSpent
from sales sale 
join product pro
	on sale.product_id = pro.product_id
group by   sale.userid ;

-- Q-2: How many days has each customer visited Foodpanda?

select userid , count(distinct created_date) as daysVisited
from sales
group by userid;

-- Q-3: What was the first product purchased by each customer?

select * from
(select *,
rank() over(partition by userid order by created_date) rnk
from sales) a
where rnk = 1;

-- Q-4: What is the most purchashed item on menu and how many times was it purchased by all customer?

select userid , count(product_id)
from sales
where product_id =
(select product_id
from sales
group by product_id limit 1) 
group by userid
;

-- Q-5 : Which item is the most popular for each customer?


select * from
(select * ,
row_number() over(partition by userid  order by cnt  ) rnk from
(select userid  , product_id , count(product_id) cnt
from sales
group by userid , product_id)a)b
where rnk = 1
;


select sale.userid ,sale.product_id , count(sale.product_id) , pro.product_name
from sales sale
join product pro
	on sale.product_id = pro.product_id
group by sale.userid , sale.product_id , pro.product_name ;



-- Q-7: Which item was purchased first by the customer after they became a member?


select a.userid  , a.product_id
from
(select sale.userid, sale.product_id,
rank() over(partition by user.userid order by created_date ) rnk
from users user
join sales sale 
	on user.userid = sale.userid) a
where a.rnk = 1
;



-- Q-8: Which item was purchased just before the customer became a member?

select a.userid , a.product_id, a.created_date , a.rnk

from
(select sale.userid , sale.product_id , sale.created_date, member.gold_signup_date,
rank() over(partition by sale.userid order by sale.created_date asc) as rnk
from goldusers_signup member
join sales sale
	on member.userid = sale.userid	
) a
where a.created_date < a.gold_signup_date and  rnk = 1 
;



select 
    a.userid, 
    a.product_id,
    a.gold_signup_date,
    a.created_date
from (
    select 
        sale.userid, 
        sale.product_id,
        member.gold_signup_date,
        sale.created_date,
        rank() over (partition by sale.userid order by sale.created_date asc) as rnk
    from 
        goldusers_signup member
    join 
        sales sale
        on member.userid = sale.userid
) a
where 
    a.gold_signup_date < a.created_date 
    and a.rnk = 1;



-- Q-9: What is the total orders and amount spent for each member before they become a member?


select userid , count(created_date) , sum(price)
from
(select demo.*
from
(select sale.userid , sale.product_id , sale.created_date, member.gold_signup_date,
rank() over(partition by sale.userid order by sale.created_date asc) as rnk
from sales sale
join goldusers_signup member
	on sale.userid = member.userid) 
demo
where demo.created_date < demo.gold_signup_date) b
join product p
	on b.product_id = p.product_id
group by userid
;


-- Q-10: If buying each products generate points for eg 5rs = 2 Foodpanda points and each products has different purchasing points for eg 
-- for p1 5tk = 1 Foodpanda points , for p2 10tk = 5 Foodpanda points , for p3 5tk = 1 Foodpanda points ?  

select b.userid  , b.product_name , sum(b.total_points) as total_points
from
(select a.userid , pro.product_id  , pro.price, pro.product_name,
 CASE 
        WHEN pro.product_name = 'p1' THEN pro.price / 5
        WHEN pro.product_name = 'p2' THEN (pro.price / 10)
        WHEN pro.product_name = 'p3' THEN (pro.price / 5)
        ELSE '1'
    END AS total_points
from
(select userid  
from sales
 ) a
join product pro
	on pro.product_id in (select product_id from sales))b
group by userid , product_name 
;



-- Q-11: In the first one year after a customer joins the gold program (including their joining date) irrespective 
--  of what the customer has purchased they earn 5 Foodpanda points for every 10tk spent who earned more 1 or 3?


select a.* , pro.price , pro.price * 0.5 as points
from
(select sale.userid , sale.product_id , member.gold_signup_date , sale.created_date
from sales sale 
join goldusers_signup member
	on sale.userid = member.userid
WHERE sale.created_date >= member.gold_signup_date
      AND sale.created_date <= DATE_ADD(member.gold_signup_date, INTERVAL 1 YEAR)) a
join product pro
	on a.product_id = a.product_id;



-- Q-12: Rank all the transaction of the customer ?


select *,
rank() over(partition by userid  order by created_date desc)
from sales;


-- Q-12: Rank all the transaction of the each customer whenever they are a Foodpanda gold member for every non-gold member marked as 'na' ?

select a.* , 
case
	when gold_signup_date is null then 'Na' else
	rank() over(partition by userid order by created_date desc)
end as rnk
from
(select sale.userid , sale.created_date , member.gold_signup_date
from sales sale 
left join goldusers_signup member
	on sale.userid = member.userid) a 
;






