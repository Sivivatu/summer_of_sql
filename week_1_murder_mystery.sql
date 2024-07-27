-- STEP ONE: crime Reports
-- check for crime report
select * from crime_scene_report
where type= "murder"              
and city = "SQL City";

-- date	type	description	city
-- 20180215	murder	REDACTED REDACTED REDACTED	SQL City
-- 20180215	murder	Someone killed the guard! He took an arrow to the knee!	SQL City
-- 20180115	murder	Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave".	SQL City

-- STEP TWO: WITNESS NAMES
-- find witnesses
-- first person: Northwestern Dr

Select * from person
where address_street_name = "Northwestern Dr" 
order by address_number desc
limit 1;

-- id	name	license_id	address_number	address_street_name	ssn
-- 14887	Morty Schapiro	118009	4919	Northwestern Dr	111564949

-- second person: Franklin Ave
Select * from person
where address_street_name = "Franklin Ave" 
    and name like 'Annabel%';

-- id	name	license_id	address_number	address_street_name	ssn
-- 16371	Annabel Miller	490173	103	Franklin Ave	318771143

-- STEP THREE: WITNESS STATEMENTS
-- find witness statements

select * from interview
where person_id in (14887, 16371);

-- person_id	transcript
-- 14887	I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".
-- 16371	I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.


-- STEP FOUR: ISOLATE MURDERER
-- Find gym logins on January 9th
select * from get_fit_now_check_in c
where c.check_in_date = 20180109
and c. membership_id like '48Z%'

-- membership_id	check_in_date	check_in_time	check_out_time
-- 48Z7A	20180109	1600	1730
-- 48Z55	20180109	1530	1700

-- Find person ids that match the logins
select 
    c.membership_id,
    m.person_id,
    m.name,
    m.membership_status 
from get_fit_now_check_in c
join get_fit_now_member m 
on c.membership_id = m.id
where c.check_in_date = 20180109
and c. membership_id like '48Z%'

-- membership_id	person_id	name	membership_status
-- 48Z7A	28819	Joe Germuska	gold
-- 48Z55	67318	Jeremy Bowers	gold

-- find driver licence plate matching person_id
select sus.person_id,
    sus.name
     from 
(select 
    c.membership_id,
    m.person_id,
    m.name,
    m.membership_status 
from get_fit_now_check_in c
join get_fit_now_member m 
on c.membership_id = m.id
where c.check_in_date = 20180109
and c. membership_id like '48Z%') sus
join
(select 
    dl.plate_number,
    p.id,
    p.name
from drivers_license dl
join person p on p.license_id = dl.id
where plate_number like '%H42W%' ) as car
on car.id = sus.person_id

-- person_id	name
-- 67318	Jeremy Bowers

-- The Suspect is Jeremy Bowers