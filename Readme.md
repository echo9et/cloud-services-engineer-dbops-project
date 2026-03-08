# dborder_products-project

## Создание БД
CREATE DATABASE store; 

1. Создаём пользователя 
```sql
CREATE USER <user> WITH PASSWORD '<password>';
```

2. Выдача привилегий на работу базы данных 
```sql
GRANT ALL PRIVILEGES ON DATABASE store TO <user>;
GRANT ALL PRIVILEGES ON SCHEMA public TO <user>;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO <user>;
```

## Колличество проданных сосисок за последние 7 дней
```sql
SELECT
  orders.date_created,                
  SUM(order_product.quantity) AS total_sold
FROM orders
JOIN order_product
  ON orders.id = order_product.order_id
WHERE orders.date_created >= (date_trunc('week', CURRENT_DATE)::date - INTERVAL '1 week')
  AND orders.date_created < date_trunc('week', CURRENT_DATE)::date
GROUP BY
  orders.date_created
ORDER BY
  orders.date_created;
```

**Время выполнения без индексов: `~54 сек`**
```
 Finalize GroupAggregate  (cost=200938.42..201159.79 rows=200 width=12) (actual time=53757.704..54013.507 rows=7 loops=1)
   Group Key: orders.date_created
   ->  Gather Merge  (cost=200938.42..201155.79 rows=400 width=12) (actual time=53745.392..54013.424 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Partial GroupAggregate  (cost=199938.40..200109.60 rows=200 width=12) (actual time=53546.546..53590.510 rows=7 loops=3)
               Group Key: orders.date_created
               ->  Sort  (cost=199938.40..199994.80 rows=22560 width=8) (actual time=53532.259..53562.819 rows=258657 loops=3)
                     Sort Key: orders.date_created
                     Sort Method: external merge  Disk: 4136kB
                     Worker 0:  Sort Method: external merge  Disk: 5256kB
                     Worker 1:  Sort Method: external merge  Disk: 4320kB
                     ->  Parallel Hash Join  (cost=77651.51..198307.14 rows=22560 width=8) (actual time=52518.916..53453.735 rows=258657 loops=3)
                           Hash Cond: (order_product.order_id = orders.id)
                           ->  Parallel Seq Scan on order_product  (cost=0.00..108812.29 rows=4511729 width=12) (actual time=2.181..31667.283 rows=3333333 loops=3)
                           ->  Parallel Hash  (cost=77628.28..77628.28 rows=1858 width=12) (actual time=20198.121..20198.122 rows=258657 loops=3)
                                 Buckets: 131072 (originally 8192)  Batches: 8 (originally 1)  Memory Usage: 5664kB
                                 ->  Parallel Seq Scan on orders  (cost=0.00..77628.28 rows=1858 width=12) (actual time=14.349..20023.855 rows=258657 loops=3)
                                       Filter: ((date_created < (date_trunc('week'::text, (CURRENT_DATE)::timestamp with time zone))::date) AND (date_created >= ((date_trunc('week'::text, (CURRENT_DATE)::timestamp with time zone))::date - '7 days'::interval)))
                                       Rows Removed by Filter: 3074676
 Planning Time: 63.916 ms
 JIT:
   Functions: 57
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 39.128 ms, Inlining 0.000 ms, Optimization 1.506 ms, Emission 27.119 ms, Total 67.753 ms
 Execution Time: 54015.628 ms
```

**Время выполнения с индексами: `~8 сек`**
```
 Finalize GroupAggregate  (cost=190235.29..190258.10 rows=90 width=12) (actual time=8220.483..8290.384 rows=7 loops=1)
   Group Key: orders.date_created
   ->  Gather Merge  (cost=190235.29..190256.30 rows=180 width=12) (actual time=8220.468..8290.367 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=189235.27..189235.50 rows=90 width=12) (actual time=8170.784..8170.788 rows=7 loops=3)
               Sort Key: orders.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               ->  Partial HashAggregate  (cost=189231.45..189232.35 rows=90 width=12) (actual time=8170.759..8170.763 rows=7 loops=3)
                     Group Key: orders.date_created
                     Batches: 1  Memory Usage: 24kB
                     Worker 0:  Batches: 1  Memory Usage: 24kB
                     Worker 1:  Batches: 1  Memory Usage: 24kB
                     ->  Parallel Hash Join  (cost=28996.31..187590.47 rows=328195 width=8) (actual time=7317.312..8130.428 rows=258657 loops=3)
                           Hash Cond: (order_product.order_id = orders.id)
                           ->  Parallel Seq Scan on order_product  (cost=0.00..105361.67 rows=4166667 width=12) (actual time=0.047..6266.263 rows=3333333 loops=3)
                           ->  Parallel Hash  (cost=23290.93..23290.93 rows=328190 width=12) (actual time=146.263..146.264 rows=258657 loops=3)
                                 Buckets: 262144  Batches: 8  Memory Usage: 6688kB
                                 ->  Parallel Index Only Scan using idx_orders_date_created_id on orders  (cost=0.46..23290.93 rows=328190 width=12) (actual time=13.227..92.257 rows=258657 loops=3)
                                       Index Cond: ((date_created >= ((date_trunc('week'::text, (CURRENT_DATE)::timestamp with time zone))::date - '7 days'::interval)) AND (date_created < (date_trunc('week'::text, (CURRENT_DATE)::timestamp with time zone))::date))
                                       Heap Fetches: 0
 Planning Time: 35.179 ms
 JIT:
   Functions: 48
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 20.088 ms, Inlining 0.000 ms, Optimization 1.132 ms, Emission 23.996 ms, Total 45.217 ms
 Execution Time: 8291.354 ms
```

### Итог

| Метрика                  | Без индексов (мс)   | С индексами  (мс) |
|--------------------------|---------------------|-------------------|
| Время выполнения         | 54015.628           | 8291.354          |
| Planning Time            | 63.916              | 35.179            |

Время: выполнения запроса при использование индексов сократилось в ~6.5 раз.