select*from dataset1;
select*from dataset2;
select count(*) from dataset1;
select count(*) from dataset2;
#dataset for maharashtra#
select*from dataset1 where state="maharashtra";
#population in india#
select sum(population) as sum_of_population from dataset2;
#avg growth#
select state,avg(growth) as avg_growth_pct from dataset1 group by State;
#avg sex ratio#
select state,round(avg(sex_ratio),0) as avg_sex_ratio from dataset1 group by state order by avg_sex_ratio desc;
#avg literacy rate#
select state,round(avg(literacy),0) as avg_literacy_ratio from dataset1 
group by state having round(avg(literacy),0)>90 order by round(avg(literacy),0) desc;
#top 3 states showing highest growth rate#

select state,avg(growth)*100 as avg_growth from dataset1 group by state order by avg_growth desc limit 3;
#bottom 3 states showing highest growth rate#
select state,round(avg(growth),0)*100 as avg_growth from dataset1 group by state order by avg_growth asc limit 3;
#bottom 3 state showing lowest sex ratio#
select state, round(avg(sex_ratio),0) as avg_sex_ratio from dataset1 group by state order by avg_sex_ratio asc limit 3;


#top & bottom 3 state in literacy rate#
drop table if exists literacy_affair;
create table literacy_affair (state varchar(45),topstates float);
insert into literacy_affair
select state,round(avg(literacy),0) as avg_literacy_ratio from dataset1 group by state order by avg_literacy_ratio desc limit 3;
select*from literacy_affair;



create table literacy_affair_bottom (state varchar(45),bottomstates float);
insert into literacy_affair_bottom
select state,round(avg(literacy),0) as avg_literacy_ratio from dataset1 group by state order by avg_literacy_ratio asc limit 3;
select*from literacy_affair_bottom;

#union#
select*from literacy_affair
union
select*from literacy_affair_bottom;

#states starting with letter A# OR B#
select DISTINCT(STATE) FROM DATASET1 WHERE STATE LIKE "A%" OR  STATE LIKE "B%";
# STATES STARTING WITH A AND ENDING WITH D#
select DISTINCT(STATE) FROM DATASET1 WHERE STATE LIKE "A%" AND  STATE LIKE "%M";


#JOINING TABLE and total male female using Sumqueries#
select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 as sex_ratio,b.population from dataset1 a join dataset2 b on a.district=b.district ) c) d
group by d.state;

#total literacy rate common table expression#
with cte1 as(
with cte as
(select a.district,a.state,a.literacy/100 as literacy_ratio,
b.population from dataset1 as a inner join dataset2 as b
 on a.district=b.district)
 select district,state,round(literacy_ratio*population,0) as literate_people,round((1-literacy_ratio)*population,0)
 as illiterate_people from cte)
 select state,sum(literate_people),sum(illiterate_people) from cte1 group by state;
 
 #previos census#
 select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from dataset1 a inner join dataset2 b on a.district=b.district) d) e
group by e.state)m;
 
 #population vs area#

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from dataset1 a inner join dataset2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from dataset2)z) r on q.keyy=r.keyy)g;

# use of WINDOW FUNCTION output top 3 districts from each state with highest literacy rate#


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from dataset1) a

where a.rnk in (1,2,3) order by state;

