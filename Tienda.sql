-- TABLAS
-- empleado
CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE,
    address VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    supervisor_id INT REFERENCES employee(employee_id)
);

-- cliente
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    company VARCHAR(100),
    email VARCHAR(100),
    address VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)
);

-- categoria
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    description TEXT,
    parent_category INT
);

-- producto
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT REFERENCES category(category_id),
    quantity_per_unit VARCHAR(50),
    unit_price NUMERIC(10,2),
    units_in_stock INT,
    discontinued BOOLEAN
);

-- compra
CREATE TABLE purchase (
    purchase_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(customer_id),
    employee_id INT REFERENCES employee(employee_id),
    total_price NUMERIC(10,2),
    purchase_date DATE DEFAULT CURRENT_DATE,
    shipping_details TEXT
);

-- detalle de compra
CREATE TABLE purchase_item (
    purchase_item_id SERIAL PRIMARY KEY,
    purchase_id INT REFERENCES purchase(purchase_id),
    product_id INT REFERENCES product(product_id),
    unit_price NUMERIC(10,2),
    quantity INT
);
----------------------------------------------------------------------

-- DATOS
-- categoria
INSERT INTO category (name, description) VALUES
('Alimentos', 'Comida en general'),
('Bebidas', 'Líquidos para consumo'),
('Lácteos', 'Productos de leche'),
('Carnes', 'Carnes rojas y blancas'),
('Frutas y Verduras', 'Productos frescos');

-- producto
INSERT INTO product (product_name, category_id, quantity_per_unit, unit_price, units_in_stock, discontinued) VALUES
('Manzana', 5, '1kg', 4.00, 50, false),
('Leche Entera', 3, '1L', 2.50, 30, false),
('Pan Integral', 1, '500g', 3.80, 20, false),
('Carne de Res', 4, '1kg', 10.00, 15, false),
('Zanahoria', 5, '1kg', 3.20, 40, false);

-- empleado
INSERT INTO employee (first_name, last_name, birth_date, address, city, country)
VALUES 
('Juan', 'Pérez', '1985-04-12', 'Calle 123', 'Bogotá', 'Colombia'),
('Ana', 'Gómez', '1990-06-20', 'Carrera 45', 'Medellín', 'Colombia'),
('Carlos', 'López', '1978-01-30', 'Av. Siempre Viva', 'Cali', 'Colombia');

-- cliente
INSERT INTO customer (name, company, email, address, city, country)
VALUES
('Luis Martínez', 'LM Corp', 'luis@mail.com', 'Calle Luna 12', 'Bogotá', 'Colombia'),
('María Fernández', 'MF Ltda', 'maria@mail.com', 'Calle Sol 34', 'Medellín', 'Colombia'),
('Pedro Ruiz', 'PR S.A.', 'pedro@mail.com', 'Av. Central 56', 'Cali', 'Colombia');

--purchase
INSERT INTO purchase (customer_id, employee_id, total_price, purchase_date, shipping_details)
VALUES
(1, 1, 20.50, '2023-08-10', 'Calle Luna 12'),
(2, 2, 35.00, '2023-08-12', 'Calle Sol 34'),
(3, 3, 15.00, '2023-08-15', 'Av. Central 56');

-- purchase_item
INSERT INTO purchase_item (purchase_id, product_id, unit_price, quantity)
VALUES
(1, 1, 4.00, 2),   -- manzana
(1, 2, 2.50, 3),   -- leche
(2, 4, 10.00, 2),  -- carne
(2, 3, 3.80, 1),   -- pan
(3, 5, 3.20, 2);   -- zanahoria
----------------------------------------------------------------------------------

-- CONSULTAS
--Primera consulta
SELECT * 
FROM product
WHERE category_id IN (1, 5)
  AND unit_price > 3.5;

--Segunda consulta
SELECT product_name
FROM product
WHERE unit_price >= 3.5;

--Tercera consulta
SELECT p.product_name, c.name AS category_name
FROM product p
JOIN category c ON p.category_id = c.category_id;

--Cuarta consulta
SELECT pi.purchase_id, p.product_name, pi.unit_price, pi.quantity
FROM purchase_item pi
JOIN product p ON pi.product_id = p.product_id;

--Quinta consulta
SELECT DISTINCT pi.purchase_id, c.name AS category_name
FROM purchase_item pi
JOIN product p ON pi.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id;

--Sexta consulta
SELECT last_name, first_name, birth_date
FROM employee
ORDER BY birth_date ASC;

--Septima Consulta
SELECT city, COUNT(*) AS customers_quantity
FROM customer
WHERE city NOT IN ('Knoxville', 'Stockton')
GROUP BY city
ORDER BY city ASC;

--Octava consulta
SELECT c.name, COUNT(*) AS discontinued_products_number
FROM product p
JOIN category c ON p.category_id = c.category_id
WHERE p.discontinued = true
GROUP BY c.name
HAVING COUNT(*) >= 3
ORDER BY discontinued_products_number DESC;

select * from purchase_item;