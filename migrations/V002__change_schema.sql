-- нормализация структуры базы данных

-- перенос price из product_info в product
ALTER TABLE product
    ADD COLUMN price DOUBLE PRECISION;

UPDATE product p
SET    price = pi.price
FROM   product_info pi
WHERE  p.id = pi.product_id;

-- перенос date_created из orders_date в orders
ALTER TABLE orders
    ADD COLUMN date_created DATE;

UPDATE orders o
SET    date_created = od.date_created,
       status = COALESCE(o.status, od.status) 
FROM   orders_date od
WHERE  o.id = od.order_id;

-- первичные ключи
ALTER TABLE product
    ADD PRIMARY KEY (id);

ALTER TABLE orders 
    ADD PRIMARY KEY (id);

-- внешние ключи для order_product
ALTER TABLE order_product
    ADD CONSTRAINT fk_order_product_product
        FOREIGN KEY (product_id) REFERENCES product(id),
    ADD CONSTRAINT fk_order_product_order
        FOREIGN KEY (order_id) REFERENCES orders(id);

-- удаление ненужными таблиц
DROP TABLE product_info;
DROP TABLE orders_date;