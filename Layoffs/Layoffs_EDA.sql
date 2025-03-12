select *
from parks_and_recreation.employee_demographics;


SELECT age + 10, birth_date
FROM parks_and_recreation.employee_demographics;

SELECT gender, avg(age), max(age), min(age), count(age)
FROM parks_and_recreation.employee_demographics
group by gender;

SELECT gender, avg(age)
FROM parks_and_recreation.employee_demographics
group by gender
having avg(age) > 40;

SELECT occupation, avg(salary)
FROM employee_salary
where occupation like '%manager%'
group by occupation
having avg(salary) > 75000;

SELECT *
FROM employee_demographics
order by age desc
limit 3,1;


SELECT *
FROM employee_demographics
join employee_salary
on employee_demographics.employee_id = employee_salary.employee_id
;


SELECT *
FROM employee_salary emp1
join employee_salary emp2
on emp1.employee_id +1 = emp2.employee_id
;

SELECT emp1.employee_id as emp_santa,
emp1.first_name as first_name_santa,
emp1.last_name as last_name_santa,
emp2.employee_id as emp_id,
emp2.first_name as first_name_emp,
emp2.last_name as last_name_emp
FROM employee_salary emp1
join employee_salary emp2
on emp1.employee_id +1 = emp2.employee_id
;


SELECT *
FROM employee_demographics dem
join employee_salary sal
	on dem.employee_id = sal.employee_id
inner join parks_departments pd
	on sal.dept_id = pd.department_id
;

-- union

select first_name, last_name
from employee_demographics
union ALL
select first_name, last_name
from employee_salary
; 

select first_name, last_name, 'OLD Man' as label
from employee_demographics
WHERE age > 40 and gender = 'male'
union
select first_name, last_name, 'OLD Female' as label
from employee_demographics
WHERE age > 40 and gender = 'female'
union
select first_name, last_name, 'highly paid employee' as label
from employee_salary 
where salary > 70000
order by first_name, last_name
; 


-- string function

SELECT LENGTH('skyfall');

select first_name, length(first_name)
from employee_demographics;

select first_name, upper(first_name), last_name, lower(last_name)
from employee_demographics;

select ltrim('           sky                   ');

select first_name, left(first_name,3)
from employee_demographics;

select first_name, left(first_name,3),
right(first_name, 4),
substring(first_name, 3,3)
from employee_demographics;


select first_name, replace(first_name,'a','z')
from employee_demographics;

select first_name, locate('a',first_name)
from employee_demographics;

select first_name, last_name,
concat(first_name, ' ', last_name) as name
from employee_demographics;

-- case statement

select first_name, last_name, age,
case 
	when age <= 30 then 'young'
    when age between 31 and 50 then 'old'
    when age >= 50 then 'on deaths door'
end as 'age grade'
from employee_demographics;

select first_name, last_name, salary,
case
	when salary < 50000 then salary +(salary*5/100)
    when salary > 50000 then salary + (salary *7/100)
    
end as 'new_sal',
case
	when dept_id = 6 then salary*10/100
end 'bonus'
from employee_salary;

select *
from parks_departments;

-- subqueries

select *
from employee_demographics
where employee_id in 
(
select employee_id
from employee_salary
where dept_id =1
);

select first_name, salary,
(select avg(salary)
from employee_salary) as 'sal'
from employee_salary;

-- window functions 
select gender, dem.first_name, sal.salary, avg(age) over(partition by gender)
from employee_demographics dem
join employee_salary sal
on dem.employee_id=sal.employee_id;

select dem.employee_id, dem.first_name, dem.last_name, gender, sal.salary, 
sum(salary) over(partition by gender order by dem.employee_id)
from employee_demographics dem
join employee_salary sal
on dem.employee_id=sal.employee_id;

select dem.employee_id, dem.first_name, dem.last_name, gender, sal.salary, 
row_number() over(partition by gender order by dem.employee_id),
sum(salary) over(partition by gender order by dem.employee_id)
from employee_demographics dem
join employee_salary sal
on dem.employee_id=sal.employee_id;

-- CTE 
with CTE_Example AS
(
select gender, avg(age) as avg_sal,
max(salary) max_sal,
min(salary) min_sal,
count(salary) count_sal
from employee_demographics dem
join employee_salary sal
	on dem.employee_id=sal.employee_id
group by gender
)
Select *
From CTE_Example
;

-- creatinf temporary table

create temporary table temp_table
(first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
);

-- create procedure

create procedure large_salaries()
select *
from employee_salary
where salary >= 50000;

call large_salaries();

DROP procedure IF EXISTS large_salaries2;

DELIMITER $$
create procedure large_salaries2()
BEGIN
	select *
	from employee_salary
	where salary >= 50000;
	select *
	from employee_salary
	where salary >= 10000;
END $$
DELIMITER ;


DELIMITER $$
create procedure large_salaries3(employee int)
BEGIN
	select *
	from employee_salary
    where employee_id=employee
	;
END $$
DELIMITER ;

call large_salaries3(1);

-- trigger and events

DELIMITER $$
create trigger employee_insert
	after insert on employee_salary
    for each row
	BEGIN
		insert into employee_demographics (employee_id, first_name, last_name)
        values (new.employee_id, new.first_name, new.last_name);
	END $$
DELIMITER ;

insert into employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
values(13, 'Jean-Ralphio', 'Saperstein', 'Entertainment 720 CEO', '10000000', null);

update employee_demographics 
set age =34, gender='Male', birth_date='1980-05-15'
where employee_id =13;


select * from employee_demographics;

drop event if exists `delete_retirees`;
-- events
delimiter $$
create event delete_retirees
on schedule every 30 second
do
begin
	delete
    from employee_demographics
    where age >= 60;

end $$
delimiter ;