/*
There are 2 csv files present in this zip file. The data contains 120 years of olympics history. There are 2 daatsets 
1- athletes : it has information about all the players participated in olympics
2- athlete_events : it has information about all the events happened over the year.(athlete id refers to the id column in athlete table)

import these datasets in sql server and solve below problems:

--1 which team has won the maximum gold medals over the years.

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

--6 find players who won gold medal in summer and winter olympics both.

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
*/

select * from athletes
select * from athlete_events



--Q)--1 which team has won the maximum gold medals over the years.


with infoCte as
(select a1.name,a1.team,a2.year,a2.event,a2.medal
from athletes a1
inner join
athlete_events a2
on a1.id=a2.athlete_id
where medal='Gold'),
finalReport as
(select team,count(distinct event) as medal_count
from infoCte
group by team)
select top 1 team,sum(medal_count) as total_gold_medal
from finalReport
group by team
order by total_gold_medal desc



--Q2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver



with infoCte as
(select a1.team,a2.year,a2.event,a2.medal
from athletes a1
inner join
athlete_events a2
on a1.id=a2.athlete_id
where medal='Silver'),
finalReport as
(select team,year,count(distinct event) as total_silver_medals,
rank()over(partition by team order by count(distinct event) desc) rn
from infoCte
group by team,year)
select team,count(total_silver_medals) silver_medals,max(case when rn=1 then year end) max_year
from finalReport
group by team
order by silver_medals desc


--Q3) which player has won maximum gold medals  amongst the players 
--    which have won only gold medal (never won silver or bronze) over the years

with infoCte as
(select a1.team,a1.name,a2.year,a2.event,a2.medal
from athletes a1
inner join
athlete_events a2
on a1.id=a2.athlete_id)
select top 1 name , count(1) as no_of_gold_medals
from infoCte 
where name not in (select distinct name from infoCte where medal in ('Silver','Bronze'))
and medal='Gold'
group by name
order by no_of_gold_medals desc



--Q)4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

with infoCte as (
select a1.year,a2.name,count(1) as no_of_gold
from athlete_events a1
inner join athletes a2 on a1.athlete_id=a2.id
where medal='Gold'
group by a1.year,a2.name)
select year,no_of_gold,STRING_AGG(name,',') as players from (
select *,
rank() over(partition by year order by no_of_gold desc) as rn
from infoCte) a where rn=1
group by year,no_of_gold
;




--Q5) in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport


select * from athletes
select * from athlete_events

select distinct * from (
select medal,year,event,rank() over(partition by medal order by year) rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where team='India' and medal != 'NA'
) A
where rn=1


--6 find players who won gold medal in summer and winter olympics both.


select * from athletes
select * from athlete_events

with reportCte as
(select a1.name,a2.season,a2.event,a2.medal from
athletes a1 inner join athlete_events a2
on a1.id=a2.athlete_id)
select name
from reportCte
where medal='Gold'
group by name
having count(distinct season)=2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select * from athletes
select * from athlete_events


with reportCte as
(select a1.name,a2.season,a2.event,a2.medal,a2.year from
athletes a1 inner join athlete_events a2
on a1.id=a2.athlete_id)
select year,name from reportCte
where medal!='NA'
group by year,name
having count(distinct medal)=3


--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with cte as (
select name,year,event
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where year >=2000 and season='Summer'and medal = 'Gold'
group by name,year,event)
select * from
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte) A
where year=prev_year+4 and year=next_year-4




