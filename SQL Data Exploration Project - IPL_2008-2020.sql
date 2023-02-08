drop table if exists ipl;

create table ipl
(
id	float,
inning	float,
overr	float,
ball	float,
batsman	nvarchar(255),
non_striker	nvarchar(255),
bowler	nvarchar(255),
batsman_runs	float,
extra_runs	float,
total_runs	float,
non_boundary	float,
is_wicket	float,
dismissal_kind	nvarchar(255),
player_dismissed	nvarchar(255),
fielder	nvarchar(255),
extras_type	nvarchar(255),
batting_team	nvarchar(255),
bowling_team nvarchar(255)
)

insert into ipl
select * from [dbo].[ipl1]
union
select * from [dbo].[ipl2]
union
select * from [dbo].[ipl3]
union
select * from [dbo].[ipl4];

select count(*) from ipl;
select count(*) from [dbo].[ipl1]
select count(*) from [dbo].[ipl2]
select count(*) from [dbo].[ipl3]
select count(*) from [dbo].[ipl4]
select count(*) from [dbo].[iplm]

select count(*) from ipl
select count(*) from [dbo].[iplm]

select * from ipl
select * from iplm

use [IPL Database]

--FINDING INSIGHTS FROM IPL DATABASE 2008-2020

--Q1 total no of matches played between 2008-2020

select count(id) no_of_matches from iplm

--Q2 total no of matches played in each season

select year(date) season, count(id) total_matches from iplm
group by year(date)
order by year(date)

--Q3 most player of match awards in each season

select player_of_match, total_mom, season, rank() over (partition by season order by total_mom desc) rnk from 
(select player_of_match, year(date) season, count(player_of_match) total_mom from iplm
group by player_of_match, year(date)) sub

--Q4 most no of matches won by a team over 2008-2020

select winner, count(winner) as total_wins from iplm
group by winner
order by count(winner) desc

--Q5 most no of matches at a venue over 2008-2020

select top 5 venue, count(venue) as total_matches from iplm
group by venue
order by count(venue) desc

--Q6 batsman with most runs and highest strike rate over 2008-2020

select top 5 batsman, total_runs, (total_runs/total_balls)*100 as strike_rate from 
(select batsman, sum(batsman_runs) total_runs, count(ball) as total_balls from ipl
group by batsman) sub
order by total_runs desc

--Q7 batsman with most runs in each season

select iplm.year(date), ipl.batsman, sum(ipl.batsman_runs) total_runs, count(ipl.ball) as total_balls from ipl
group by batsman
order by total_runs desc
join iplm on ipl.id = iplmid

--Q8 batsman with most no of sixes over 2008-2020

select top 5 batsman, count(batsman_runs) as total_sixes from ipl
where batsman_runs=6
group by batsman
order by count(batsman_runs) desc

--Q9 batsman with most no of fours over 2008-2020

select top 5 batsman, count(batsman_runs) as total_sixes from ipl
where batsman_runs=4
group by batsman
order by count(batsman_runs) desc

--Q10 bowlers with most no of fours over 2008-2020

select top 5 bowler, count(is_wicket) as total_wickets from ipl
where is_wicket=1
group by bowler
order by count(is_wicket) desc

--Q11 bowlers with best economy over 2008-2020

select bowler, total_balls, runs_given, (runs_given/total_balls) as economy_rate from 
(select top 10 bowler, count(bowler)/6 as total_balls, sum(total_runs) as runs_given from ipl
group by bowler)sub
order by economy_rate

