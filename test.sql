vdkadhnlvfjchaldvfhnaldsvhnladhkval

-- ALL Використовується для порівняння значення з усіма значеннями, що повертає підзапит.

select 
	campaign_name,
	ad_date,
	spend 
from google_ads_basic_daily 
where spend >= ALL (
				select 
					spend 
				from google_ads_basic_daily 
				where campaign_name = 'Electronics'
				)
;

-- ANY (SOME) Порівнює значення з будь-яким значенням, що повертає підзапит
select 
	campaign_name,
	ad_date,
	spend 
from google_ads_basic_daily 
where spend >= ANY (
				select 
					spend 
				from google_ads_basic_daily 
				where campaign_name = 'Electronics' and spend > 0
				)
;

select 
	campaign_name,
	ad_date,
	spend 
from google_ads_basic_daily 
where spend >= SOME (
				select 
					spend 
				from google_ads_basic_daily 
				where campaign_name = 'Electronics' and spend > 0
				)
;

-- EXISTS Перевіряє, чи підзапит повертає хоча б один рядок.
select 
	campaign_name,
	ad_date,
	spend 
from google_ads_basic_daily d1
where EXISTS (
				select 
					campaign_name 
				from google_ads_basic_daily d2
				where campaign_name = 'Electronics'
					and d2.ad_date = d1.ad_date 
				)
;

-- NOT EXISTS Перевіряє, що підзапит не повертає жодного рядка.
select 
	campaign_name,
	ad_date,
	spend 
from google_ads_basic_daily d1
where NOT EXISTS (
				select 
					campaign_name 
				from google_ads_basic_daily d2
				where campaign_name = 'Electronics'
					and d2.ad_date = d1.ad_date 
				)
;

select 
	ad_date ,
	campaign_name,
	sum(spend) as spend 
from public.google_ads_basic_daily gabd
group by ad_date , campaign_name 
;

select 
	campaign_name,
	avg(spend) as spend 
from public.google_ads_basic_daily gabd
group by campaign_name 
;

select 
	--campaign_name,
	avg(spend) as spend 
from public.google_ads_basic_daily gabd
group by campaign_name 
;

select 
	campaign_name,
	avg(spend) as spend
from
(
	select 
		ad_date ,
		campaign_name,
		sum(spend) as spend 
	from public.google_ads_basic_daily gabd
	group by ad_date , campaign_name 
) a
group by campaign_name
;


select 
	campaign_name,
	avg(spend) as avg_daily_spend,
	sum(spend) as spend,
	( select sum(spend) from public.google_ads_basic_daily gabd ) as total_spend,
	round(sum(spend) :: numeric / ( select sum(spend) from public.google_ads_basic_daily gabd ),3) as "share",
	concat( round(sum(spend) :: numeric / ( select sum(spend) from public.google_ads_basic_daily gabd ),3)*100, '%') as "share1",
	( 
		select 
			sum(value) :: numeric / sum(spend) - 1  as spend 
		from public.google_ads_basic_daily gabd
		where gabd.campaign_name = a.campaign_name
		group by campaign_name 
	
	) as romi
from
(
	select 
		ad_date ,
		campaign_name,
		sum(spend) as spend 
	from public.google_ads_basic_daily gabd
	group by ad_date , campaign_name 
) a
group by campaign_name
;


select 
	ad_date ,
	campaign_name,
	sum(spend) as spend 
from public.google_ads_basic_daily gabd
-- where ad_date > '2021-01-01'
where ad_date > ( 
			select 
				min(ad_date) 
			from public.google_ads_basic_daily s1
			where campaign_name = 'Promos')
group by ad_date , campaign_name 
;




select 
	campaign_name,
    AVG(daily_spend) as avg_daily_spend
from (
	select 
		ad_date,
    	campaign_name,
        SUM(spend) as daily_spend
    from google_ads_basic_daily
    group by 1, 2
    ) cds
group by campaign_name
;

select 
	campaign_name,
    AVG(daily_spend) as avg_daily_spend,
    sum(daily_spend) as spend,
    ( select sum(spend) from google_ads_basic_daily) as total_spend,
    sum(daily_spend) / ( select sum(spend) from google_ads_basic_daily) as spend_share,
    (  select 
    		sum( stat.value :: numeric) / sum(stat.spend) - 1 as romi_temp
    	from google_ads_basic_daily stat 
    	where stat.campaign_name = cds.campaign_name
    	group by campaign_name
    ) as romi
from (
	select 
		ad_date,
    	campaign_name,
        SUM(spend) as daily_spend
    from google_ads_basic_daily
    group by 1, 2
    ) cds
group by campaign_name
;

select 
    campaign_name,
    SUM(spend) as daily_spend,
    count( distinct ad_date) as countd_date
from google_ads_basic_daily
where spend > (select avg(spend) from google_ads_basic_daily)
group by 1
;


select 
	campaign_name,
    AVG(daily_spend) as avg_daily_spend,
    sum(daily_spend) as spend,
    ( select sum(spend) from google_ads_basic_daily) as total_spend,
    sum(daily_spend) / ( select sum(spend) from google_ads_basic_daily) as spend_share,
    (  select 
    		sum( stat.value :: numeric) / sum(stat.spend) - 1 as romi_temp
    	from google_ads_basic_daily stat 
    	where stat.campaign_name = cds.campaign_name
    	group by campaign_name
    ) as romi
from (
	select 
		ad_date,
    	campaign_name,
        SUM(spend) as daily_spend
    from google_ads_basic_daily
    group by 1, 2
    ) cds
group by campaign_name
;

with daily_stat as (
	select 
		ad_date,
    	campaign_name,
        SUM(spend) as daily_spend
    from google_ads_basic_daily
    group by ad_date, campaign_name
)
select 
	campaign_name,
	avg(daily_spend) as avg_daily_spend
from daily_stat
group by campaign_name
;

with daily_stat as (
	select 
		ad_date,
    	campaign_name,
        SUM(spend) as daily_spend
    from google_ads_basic_daily
    group by ad_date, campaign_name
),
romi as (
	select
		campaign_name,
    	sum( stat.value :: numeric) / sum(stat.spend) - 1 as romi_temp
    from google_ads_basic_daily stat 
	group by campaign_name
),
click_t as (
	select
		campaign_name,
    	sum(stat.clicks) as click
    from google_ads_basic_daily stat 
	group by campaign_name
)
select 
	campaign_name,
	avg(daily_spend) as avg_daily_spend,
	(select romi_temp from romi where romi.campaign_name = daily_stat.campaign_name ) as romi
from daily_stat
where campaign_name in ( select campaign_name from click_t where click > 10000)
group by campaign_name
;








with stat_romi  as (
select 
    stat.campaign_name, 
    sum(spend) as spend,
    sum(clicks) as clicks,
    sum( stat.value :: numeric) / sum(stat.spend) - 1 as romi_temp
from google_ads_basic_daily stat 
group by campaign_name
)
select 
	campaign_name,
	spend,
	spend :: numeric / clicks as cpc,
	romi_temp as romi
from stat_romi
where romi_temp > (select avg(romi_temp) from stat_romi)
;

with stat_romi as (
select 
    stat.campaign_name, 
    sum(spend) as spend,
    sum(clicks) as clicks,
    sum( stat.value :: numeric) / sum(stat.spend) - 1 as romi_temp
from google_ads_basic_daily stat 
group by campaign_name
),
stat_imp  as (
select 
    stat.campaign_name, 
	sum(impressions) as impressions 
from google_ads_basic_daily stat 
group by campaign_name
)
select 
	campaign_name,
	spend,
	spend :: numeric / clicks as cpc,
	round(romi_temp,4) as romi,
	(select impressions from stat_imp i where i.campaign_name = r.campaign_name)
from stat_romi r
-- where romi_temp > 0
where romi_temp > (select avg(romi_temp) from stat_romi)
;

-- UNION 

select 
	'2021' as year_id,
    stat.campaign_name, 
	sum(impressions) as impressions 
from google_ads_basic_daily stat 
where ad_date between '2021-01-01' and '2021-12-31'
group by campaign_name
union all
select 
	'2020' as year_id,
    stat.campaign_name, 
	sum(impressions) as impressions 
from google_ads_basic_daily stat 
where ad_date between '2020-01-01' and '2020-12-31'
group by campaign_name
order by year_id



select 
	'2021' as year_id,
	fabd.campaign_id,
	SUM(spend) as spend 
from public.facebook_ads_basic_daily fabd 
where ad_date between '2021-01-01' and '2021-12-31'
group by fabd.campaign_id , year_id
union all
select 
	'2022' as year_id,
	fabd.campaign_id, 
	SUM(spend) as spend 
from public.facebook_ads_basic_daily fabd 
where ad_date between '2022-01-01' and '2022-12-31'
group by fabd.campaign_id , year_id
;

select 
	'2021' as year_id,
	fabd.campaign_id
from public.facebook_ads_basic_daily fabd 
where ad_date between '2021-01-01' and '2021-12-31'
group by fabd.campaign_id , year_id
--union all
union
select 
	'2022' as year_id,
	fabd.campaign_id
from public.facebook_ads_basic_daily fabd 
where ad_date between '2022-01-01' and '2022-12-31'
group by fabd.campaign_id , year_id
;

select 
	-- '2021' as year_id,
	fabd.campaign_id
from public.facebook_ads_basic_daily fabd 
where ad_date between '2021-01-01' and '2021-12-31'
group by fabd.campaign_id
-- union
union all
select 
	-- 2022 as year_id,
	fabd.campaign_id
from public.facebook_ads_basic_daily fabd 
where ad_date between '2022-01-01' and '2022-12-31'
group by fabd.campaign_id
;



-- part 2 CREATE - Щоб створити нову сутність
drop table OS_test_table;
create table if not exists OS_test_table (
	id INT primary key,
	name  varchar(255), -- text
	age INT
);

drop table OS_test_table1;
create temp table if not exists OS_test_table1 (
	id INT primary key,
	name  varchar(255), -- text
	age INT
);


create table OS_test_table4  as
select * from OS_test_table;

select * from OS_test_table;

drop table OS_test_table_select;
create table if not exists OS_test_table_select as
select 
	fabd.ad_date ,
	sum(fabd.spend) as spend
from public.facebook_ads_basic_daily fabd 
group by 1
;

select * from OS_test_table_select;
truncate table public."OS_friends";
drop table public."OS_friends";
drop view os_friends_stat;
drop MATERIALIZED VIEW os_friends_stat_m ;


select * 
from public."OS_friends"
;


create view public.os_friends_view_new1 as
select 
	f."Season",
	COUNT(f."Episode_Title") as num_e,
	SUM(f."Duration") as duration
from public."OS_friends" f
group by 1;

select * from public.os_friends_view_new1;

create materialized view public.os_friends_mview_new1 as
select 
	f."Season",
	COUNT(f."Episode_Title") as num_e,
	SUM(f."Duration") as duration
from public."OS_friends" f
group by 1;

REFRESH MATERIALIZED VIEW os_friends_mview_new1;

select * from public.os_friends_mview_new1;


-- part 2 INSERT - використовується для вставки (чи додавання) нових записів у таблицю бази даних. ТАБЛИЦІ

insert into OS_test_table
values (4, 'Olena',33);

select * from OS_test_table;


insert into OS_test_table_select
select
	ad_date,
	sum(fabd.spend) as spend
from public.facebook_ads_basic_daily fabd 
group by 1
;

select * from OS_test_table_select;

-- part 2 UPDATE - використовується для зміни вже наявних записів у таблиці бази даних. ТАБЛИЦІ

update OS_test_table_select
set spend = -1
where spend is null;

select * from OS_test_table_select;


update OS_test_table
set id = 5
where id = 3;

update OS_test_table
set name = 'Olga'
;

select * from OS_test_table;

-- part 2 DELETE - використовується для видалення записів із таблиці бази даних.  ТАБЛИЦІ


delete from  OS_test_table_select
where ad_date is NULL;


delete from OS_test_table_select
where spend < 1000;

select * from OS_test_table_select;

delete from OS_test_table
where id = 4;


-- part 2 ALTER - використовується для зміни структури бази даних.  ТАБЛИЦІ

select * from OS_test_table_select;

alter table OS_test_table_select
add column "Romi" INT;

alter table OS_test_table_select
alter column "Romi" TYPE numeric;

alter table OS_test_table_select 
rename column "Romi" TO "Romi1";

alter table OS_test_table_select
drop column "Romi1";

-- м'яке видалення

alter table OS_test_table_select
add column "to_del" INT;

update OS_test_table_select
set "to_del" = 1
where spend < 100000;

select * from OS_test_table_select
where "to_del" is not null;

-- part 2 RENAME - використовується для перейменування об’єкта.

alter table OS_test_table_select
rename to OS_test_table_select_and_other1;

alter view os_friends_view_new1
rename to os_friends_view_new2;

alter materialized view os_friends_mview_new1
rename to os_friends_mview_new2;

-- part 2 TRUNCATE - використовується для видалення всіх записів із таблиці.  ТАБЛИЦІ

truncate table OS_test_table_select_and_other1;

select * from OS_test_table_select_and_other1;

-- part 2 DROP - використовується для видалення об’єктів із бази даних.

drop table /*if exists */ OS_test_table_select_and_other1;
drop materialized view os_friends_mview_new2;
drop view os_friends_view_new2;


with stat as 
(
	select 
		fabd.campaign_id ,
		'fb' as media,
		SUM(fabd.impressions) as impressions,
		sum(fabd.spend) as spend
	from public.facebook_ads_basic_daily fabd 
	group by fabd.campaign_id 
	union all
	select 
		gabd.campaign_name,
		'gl' as media,
		SUM(gabd.impressions) as impressions,
		sum(gabd.spend) as spend
	from public.google_ads_basic_daily gabd 
	group by gabd.campaign_name
)
select 
	sum(impressions) as total_impressions,
	sum(spend) :: numeric / sum(impressions) * 1000 as CPM
from stat
