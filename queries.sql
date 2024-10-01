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
    TO_CHAR(s.sale_date, 'Day') AS day_of_week, 
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