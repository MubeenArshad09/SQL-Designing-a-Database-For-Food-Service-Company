 --create database
 create database FoodserviceDB

 --data display
select*from consumers
select *from restaurants
select *from ratings1
select *from restaurant_cuisines

--alter table consumers
alter table consumers add primary key(Consumer_ID)

--alter table restaurants
alter table restaurants add primary key(Restaurant_ID)

--alter table ratings
alter table ratings add constraint composite_consumers_restaurants
primary key(Consumer_ID, Restaurant_ID)
alter table ratings add foreign key(Consumer_ID)  references  consumers(Consumer_ID)
alter table ratings add foreign key(Restaurant_ID)  references  restaurants(Restaurant_ID)

--alter table restaurant_cuisines
alter table restaurant_cuisines add constraint composite_restaurants_cuisine
primary key(Restaurant_ID, Cuisine)
alter table restaurant_cuisines add foreign key(Restaurant_ID) references  restaurants(Restaurant_ID)

-----------------------------------------------------------------------------------------------------------------------------------------------
--Q1) Write a query that lists all restaurants with a Medium range price 
---with open area, serving Mexican food.
------------------------------------------------------------------------------------------------------------------------------------------------
 select r.Restaurant_ID, r.Name,r.Price,r.Area,c.Cuisine from 
 restaurants r Inner Join restaurant_cuisines c
 on  r.Restaurant_ID=c.Restaurant_ID  
 where (Price= 'Medium' and cuisine = 'Mexican' and Area= 'Open')

----------------------------------------------------------------------------------------------------------------------------------------------
 --Q2 --Write a query that returns the total number of restaurants who have the overall rating as 1
 -- and are serving Mexican food. Compare the results with the total number of restaurant who have
 --the overall rating as 1 serving Italian food.
 -----------------------------------------------------------------------------------------------------------------------------------------------
 Select 
 sum (case when q1.cuisine ='Mexican' then 1 else 0 end) as mexician_restaurant,
 sum (case when q1.cuisine ='Italian' then 1 else 0 end) as italian_restaurant
 from(
 select  distinct r.Restaurant_ID,c.Cuisine
 from restaurants r Inner Join restaurant_cuisines c
 on  r.Restaurant_ID=c.Restaurant_ID  inner join ratings rt on c.Restaurant_ID =rt.Restaurant_ID
 where  Overall_Rating = 1
 ) as q1
 
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  --Another query to explain the review count of Mexican cuisine in query 2.
----------------------------------------------------------------------------------------------------------------------------------------------------------
  Select  Top 5  r.Restaurant_ID, r.Name,c.Cuisine, rt.Overall_Rating,
  count (r.Restaurant_ID) as Total_Res 
 from restaurants r Inner Join restaurant_cuisines c
 on  r.Restaurant_ID=c.Restaurant_ID  inner join ratings rt on c.Restaurant_ID =rt.Restaurant_ID
 where cuisine =  'Mexican'  and Overall_Rating = 1
 group by   r.Restaurant_ID, r.Name,c.Cuisine, rt.Overall_Rating order by count(r.Restaurant_ID) desc
 
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  --Another query to explain the review count of Italian cuisine in query 2.
----------------------------------------------------------------------------------------------------------------------------------------------------------
 Select  Top 5  r.Restaurant_ID, r.Name,c.Cuisine, rt.Overall_Rating,
 count (r.Restaurant_ID) as Total_Res from restaurants r Inner Join restaurant_cuisines c
 on  r.Restaurant_ID=c.Restaurant_ID  inner join Ratings rt on c.Restaurant_ID =rt.Restaurant_ID
 where cuisine =  'Italian'  and Overall_Rating = 1
 group by   r.Restaurant_ID, r.Name,c.Cuisine, rt.Overall_Rating  order by count(r.Restaurant_ID) desc

 -------------------------------------------------------------------------------------------------------------------------------------------------------
 --Q3-- Calculate the average age of consumers who have given a 0 rating to 
 --the 'Service_rating' column. (NB: round off the value if it is a decimal)
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 --option 1
 Select  round(AVG(Age),0) As Con_Avg_age from(
 Select co.Consumer_ID, co.Age, rt.Service_Rating from consumers co right join ratings rt 
 on co.consumer_ID= rt.Consumer_ID where Service_Rating = 0) subquery;
  --option2
 Select  round(AvG(co.age),0)  AS Con_Avg_Age from consumers co right join ratings rt 
 on co.consumer_ID= rt.Consumer_ID where Service_Rating = 0

 -----------------------------------------------------------------------------------------------------------------------------------------------------
 --Q4--Write a query that returns the restaurants ranked by the youngest consumer. 
 --You should include the restaurant name and food rating that is given by that
 --customer to the restaurant in your result. Sort the results based on food rating from high to low.
 -----------------------------------------------------------------------------------------------------------------------------------------------------
  Select r.Name, rt.Food_rating ,Co.Age from restaurants r inner join ratings rt on
 r.Restaurant_ID= rt.restaurant_ID inner join consumers co on 
 co.consumer_ID= rt.Consumer_ID
 where 
 co.age = (select min(age)
 from consumers co)
 order by rt.Food_Rating Desc

 -----------------------------------------------------------------------------------------------------------------------------------------------
 --Q5--Write a stored procedure for the query given as: Update the Service_rating of all 
 --restaurants to '2' if they have parking available, either as 'yes' or 'public'
 ----------------------------------------------------------------------------------------------------------------------------------------------
Go
Create Procedure Service_Rating @SerRat tinyint, @Park nvarchar(50)
As
Begin 																																																																																							
 Update ratings
set Service_Rating =  2 where Exists(
Select r.Restaurant_ID ,  rt.Service_Rating, r.Parking from restaurants r inner join 
ratings rt on r.Restaurant_ID  = rt.Restaurant_ID 
Where  r.Parking In('Yes', 'Public') and rt.Restaurant_ID=r.Restaurant_ID
)
End

exec Service_Rating  @SerRat = 2 ,  @Park = 'yes' 

---------------------------------------------------------------------------------------------------------------------------------------------------------
--Q6a) Nested queries-Exist
---------------------------------------------------------------------------------------------------------------------------------------------------------
 Select distinct co. Consumer_ID,co.Age, count(co.Age) as No_of_visits  from 
 Consumers co 
 inner join Ratings rt 
 on co.Consumer_ID=rt.Consumer_ID
where age= 23 and  Exists (
Select distinct c.cuisine from restaurant_cuisines c 
inner join Ratings rt on rt.Restaurant_ID=c.Restaurant_ID 
where c.Cuisine= 'Mexican' 
) group by co. Consumer_ID,co.Age order by No_of_visits desc

---------------------------------------------------------------------------------------------------------------------------------------------------------
--Q6b)Nested queries-IN
----------------------------------------------------------------------------------------------------------------------------------------------------------
Select distinct rt.Restaurant_ID , rt.Overall_Rating ,c.Cuisine from 
Ratings rt right Join restaurant_cuisines c
on  rt.Restaurant_ID =c.Restaurant_ID 
where c.cuisine in (
select  c.cuisine from restaurant_cuisines c where 
rt.Overall_Rating = 0) 
order by Cuisine

----------------------------------------------------------------------------------------------------------------------------------------------
--Q6c) System function
----------------------------------------------------------------------------------------------------------------------------------------------
Select top 10
c.cuisine, count (c.cuisine) as Count, 
iif (count (c.cuisine) >100, 'popular','average') as popular_cuisine
from restaurant_cuisines c join Ratings rt
 on rt.Restaurant_ID = c.Restaurant_ID
group by c.Cuisine
order by Count DESC ;

---------------------------------------------------------------------------------------------------------------------------------------------------
 --Q6d) Use of  having , groupby, order by class
---------------------------------------------------------------------------------------------------------------------------------------------------
 --Write a query that returns the resturants on the basis of consumers reviews. List the resturants 
 --name and cuisine type which are reviewd by more than 9 consumers and its over_all rating is 2. 
 ---------------------------------------------------------------------------------------------------------------------------------------------------
 Select  r.Restaurant_ID, r.Name,c.Cuisine, rt.Overall_Rating, 
 count (r.Restaurant_ID) as RatingCount_by_Consumer 
 from restaurants r Inner Join restaurant_cuisines c
 on  r.Restaurant_ID=c.Restaurant_ID  inner join ratings rt 
 on c.Restaurant_ID =rt.Restaurant_ID where overall_rating = 2
 group by   r.Restaurant_ID, r.Name,c.Cuisine, rt.Overall_Rating  
 having  count (r.Restaurant_ID)>9 order by RatingCount_by_Consumer desc;
    
