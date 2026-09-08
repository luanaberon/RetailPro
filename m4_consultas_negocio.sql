
USE Ventas_Tech_DB;
 
-- ============================================================
-- Consulta 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes
-- ============================================================
SELECT
    MONTH(fecha_venta)                     AS mes,
    SUM(cantidad * precio_unitario)        AS total_facturado,
    COUNT(*)                               AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)        AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
 
-- ============================================================
-- Consulta 2 — Ranking de productos
-- Top 5 de id_producto por total facturado
-- ============================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad)                          AS unidades_vendidas,
    SUM(cantidad * precio_unitario)        AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
 
-- ============================================================
-- Consulta 3 — Clientes recurrentes
-- Clientes con más de un pedido, cantidad de pedidos y total gastado
-- ============================================================
SELECT
    id_cliente,
    COUNT(*)                               AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)        AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
 
-- ============================================================
-- Consulta 4 — Meses por encima/por debajo del promedio
-- Total facturado por mes, comparado contra el promedio mensual general
-- ============================================================
WITH ventas_por_mes AS (
    SELECT
        MONTH(fecha_venta)                 AS mes,
        SUM(cantidad * precio_unitario)    AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM ventas_por_mes)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM ventas_por_mes
ORDER BY mes;
 
-- ============================================================
-- Hallazgos
-- ============================================================
-- 1. El producto 1 (Laptop Pro 15) concentra cerca del 56% de la facturación
--    total ($3600 de $6444), a pesar de representar solo 3 de las 25 unidades
--    vendidas: es el producto de mayor impacto en ingresos.
-- 2. Los 5 clientes cargados son recurrentes: cada uno realizó exactamente
--    2 pedidos, sin que ninguno concentre una frecuencia de compra mayor
--    al resto todavía.
-- 3. Todas las ventas registradas caen en marzo de 2024, por lo que la
--    Consulta 4 (comparación mensual) no es representativa con un solo mes
--    de datos, hace falta cargar ventas de más meses.
 