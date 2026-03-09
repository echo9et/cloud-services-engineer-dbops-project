-- создание индексов для оптимизации запросов

-- добаление индекса для ускорения фильтрации по date_created
CREATE INDEX idx_orders_date_created_id ON orders (date_created, id);

-- добаление индекса для ускорения JOIN между order_product и orders
CREATE INDEX idx_order_product_order_id ON order_product (order_id);