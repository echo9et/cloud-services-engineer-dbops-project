-- создание индексов для оптимизации запросов

CREATE INDEX idx_orders_date_created_id ON orders (date_created, id);

CREATE INDEX idx_order_product_order_id ON order_product (order_id);