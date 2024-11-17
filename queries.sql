-- считаем количество клиентов
select COUNT(customer_id) as customers_count from customers;
-- считаем первую десятку лучших продавцов
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller, 
    COUNT(s.sales_id) AS operations, 
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM 
    sales s
JOIN 
    employees e ON s.sales_person_id = e.employee_id
JOIN 
    products p ON s.product_id = p.product_id
GROUP BY 
    e.first_name, e.last_name
ORDER BY 
    income DESC
LIMIT 10;

-- информация о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller, 
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM 
    sales s
JOIN 
    employees e ON s.sales_person_id = e.employee_id
JOIN 
    products p ON s.product_id = p.product_id
GROUP BY 
    e.first_name, e.last_name
HAVING 
    AVG(p.price * s.quantity) < (SELECT AVG(p.price * s.quantity) 
                                 FROM sales s 
                                 JOIN products p ON s.product_id = p.product_id)
ORDER BY 
    average_income ASC;

-- выручка по дням недели 
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller, 
    LOWER(TO_CHAR(s.sale_date, 'Day')) AS day_of_week, 
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM 
    sales s
JOIN 
    employees e ON s.sales_person_id = e.employee_id
JOIN 
    products p ON s.product_id = p.product_id
GROUP BY 
    e.first_name, e.last_name, EXTRACT(DOW FROM s.sale_date), TO_CHAR(s.sale_date, 'Day')
ORDER BY 
    CASE 
        WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7
        ELSE EXTRACT(DOW FROM s.sale_date)
    END, 
    seller;

    -- считаю  количество покупателей в разных возрастных группах
SELECT
    CASE 
        WHEN age >= 16 AND age <= 25 THEN '16-25'
        WHEN age >= 26 AND age <= 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

-- считаем данные по количеству уникальных покупателей и выручке, которую они принесли
select 
TO_CHAR (sale_date, 'YYYY-MM') as selling_month,
COUNT (distinct customer_id) as total_customers,
floor(SUM (p.price * s.quantity)) as income
from products p join sales s on p.product_id = s.product_id 
group by TO_CHAR (sale_date, 'YYYY-MM')
ORDER BY 
    selling_month;

    -- отчет  о покупателях, первая покупка которых была в ходе проведения акций
    SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    MIN (sale_date) as sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
    from customers c join sales s on s.customer_id = c.customer_id 
    join employees e on e.employee_id = s.sales_person_id 
    join products p on p.product_id = s.product_id 
    where p.price = 0
    group by  c.first_name, c.last_name, e.first_name, e.last_name
    order by customer;