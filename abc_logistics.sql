CREATE DATABASE abc_logistics;
USE abc_logistics;

CREATE TABLE Dim_Date (
    date            DATE PRIMARY KEY,
    day             INT NOT NULL,
    month           INT NOT NULL,
    month_name      VARCHAR(10) NOT NULL,
    year            INT NOT NULL,
    quarter         INT NOT NULL,
    is_monsoon      BOOLEAN NOT NULL,
    day_of_week     VARCHAR(10) NOT NULL
);

CREATE TABLE Dim_TransportMode (
    transport_mode_id   INT PRIMARY KEY,
    mode_name            VARCHAR(20) NOT NULL,
    base_cost_per_ton_km DECIMAL(10,2) NOT NULL,
    avg_speed_kmph       INT NOT NULL
);

CREATE TABLE Dim_Product (
    product_id        INT PRIMARY KEY,
    product_name      VARCHAR(50) NOT NULL,
    unit              VARCHAR(10) NOT NULL,
    value_per_ton_inr DECIMAL(12,2) NOT NULL
);

CREATE TABLE Dim_Warehouse (
    warehouse_id           INT PRIMARY KEY,
    warehouse_name         VARCHAR(20) NOT NULL,
    region                 VARCHAR(20) NOT NULL,
    state                  VARCHAR(30) NOT NULL,
    capacity_tons          INT NOT NULL,
    fixed_cost_monthly_inr DECIMAL(12,2) NOT NULL,
    warehouse_type         VARCHAR(20) NOT NULL
);

CREATE TABLE Dim_Supplier (
    supplier_id              INT PRIMARY KEY,
    supplier_name            VARCHAR(50) NOT NULL,
    mode_specialization      VARCHAR(20) NOT NULL,
    contract_rate_per_km_inr DECIMAL(10,2) NOT NULL,
    fleet_size               INT NOT NULL
);

CREATE TABLE Dim_Route (
    route_id             INT PRIMARY KEY,
    origin_id            INT NOT NULL,
    destination_id       INT NOT NULL,
    distance_km          INT NOT NULL,
    terrain_type         VARCHAR(20) NOT NULL,
    available_modes      VARCHAR(50) NOT NULL,
    avg_transit_time_hrs DECIMAL(6,1) NOT NULL,
    volume_weight        DECIMAL(15,10),
    FOREIGN KEY (origin_id) REFERENCES Dim_Warehouse(warehouse_id),
    FOREIGN KEY (destination_id) REFERENCES Dim_Warehouse(warehouse_id)
);

CREATE TABLE Fact_Fuel_Prices (
    fuel_price_id       INT AUTO_INCREMENT PRIMARY KEY,
    date                DATE NOT NULL,
    region              VARCHAR(20) NOT NULL,
    fuel_type           VARCHAR(20) NOT NULL,
    price_per_liter_inr DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (date) REFERENCES Dim_Date(date)
);

CREATE TABLE Fact_Shipments (
    shipment_id           INT PRIMARY KEY,
    shipment_date         DATE NOT NULL,
    route_id              INT NOT NULL,
    origin_id             INT NOT NULL,
    destination_id        INT NOT NULL,
    product_id            INT NOT NULL,
    supplier_id           INT NOT NULL,
    quantity_tons         DECIMAL(10,1) NOT NULL,
    distance_km           INT NOT NULL,
    fuel_cost_inr         DECIMAL(12,2) NOT NULL,
    freight_cost_inr      DECIMAL(12,2) NOT NULL,
    handling_cost_inr     DECIMAL(12,2) NOT NULL,
    planned_delivery_date DATE NOT NULL,
    actual_delivery_date  DATE NULL,
    delay_days            DECIMAL(6,1) NULL,
    demurrage_cost_inr    DECIMAL(12,2) NULL,
    shipment_status       VARCHAR(20) NOT NULL,
    transport_mode_id     INT NOT NULL,
    FOREIGN KEY (shipment_date) REFERENCES Dim_Date(date),
    FOREIGN KEY (route_id) REFERENCES Dim_Route(route_id),
    FOREIGN KEY (origin_id) REFERENCES Dim_Warehouse(warehouse_id),
    FOREIGN KEY (destination_id) REFERENCES Dim_Warehouse(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES Dim_Product(product_id),
    FOREIGN KEY (supplier_id) REFERENCES Dim_Supplier(supplier_id),
    FOREIGN KEY (transport_mode_id) REFERENCES Dim_TransportMode(transport_mode_id)
);

CREATE TABLE Fact_Inventory_Snapshot (
    snapshot_id              INT AUTO_INCREMENT PRIMARY KEY,
    snapshot_date            DATE NOT NULL,
    warehouse_id             INT NOT NULL,
    product_id               INT NOT NULL,
    opening_stock_tons       DECIMAL(12,1) NOT NULL,
    stock_in_tons            DECIMAL(12,1) NOT NULL,
    stock_out_tons           DECIMAL(12,1) NOT NULL,
    closing_stock_tons       DECIMAL(12,1) NOT NULL,
    holding_cost_per_ton_inr DECIMAL(8,2) NOT NULL,
    warehouse_capacity_tons  INT NOT NULL,
    reorder_point_tons       DECIMAL(10,1) NOT NULL,
    FOREIGN KEY (snapshot_date) REFERENCES Dim_Date(date),
    FOREIGN KEY (warehouse_id) REFERENCES Dim_Warehouse(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES Dim_Product(product_id)
);

-- 2. LOAD DATA
-- update the paths below to wherever your CSVs actually sit,
-- and use forward slashes even on Windows or MySQL strips the backslashes

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/abc_project/Dataset/Dim_Date.csv'
INTO TABLE Dim_Date
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(date, day, month, month_name, year, quarter, @is_monsoon, day_of_week)
SET is_monsoon = (@is_monsoon = 'True');

LOAD DATA LOCAL INFILE 'C:/abc_project/Dataset/Dim_TransportMode.csv'
INTO TABLE Dim_TransportMode
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(transport_mode_id, mode_name, base_cost_per_ton_km, avg_speed_kmph);

LOAD DATA LOCAL INFILE 'C:/abc_project/Dataset/Dim_Product.csv'
INTO TABLE Dim_Product
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(product_id, product_name, unit, value_per_ton_inr);

LOAD DATA LOCAL INFILE 'C:/abc_project/Dataset/Dim_Warehouse.csv'
INTO TABLE Dim_Warehouse
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(warehouse_id, warehouse_name, region, state, capacity_tons, fixed_cost_monthly_inr, warehouse_type);

LOAD DATA LOCAL INFILE 'C:/abc_project/Dataset/Dim_Supplier.csv'
INTO TABLE Dim_Supplier
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(supplier_id, supplier_name, mode_specialization, contract_rate_per_km_inr, fleet_size);

LOAD DATA LOCAL INFILE 'C:/abc_project/Dataset/Dim_Route.csv'
INTO TABLE Dim_Route
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(route_id, origin_id, destination_id, distance_km, terrain_type, available_modes, avg_transit_time_hrs, volume_weight);

LOAD DATA LOCAL INFILE 'C:/abc_project/Dataset/Fact_Fuel_Prices.csv'
INTO TABLE Fact_Fuel_Prices
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(date, region, fuel_type, price_per_liter_inr);


LOAD DATA LOCAL INFILE 'C:/abc_project/Dataset/Fact_Shipments.csv'
INTO TABLE Fact_Shipments
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(shipment_id, shipment_date, route_id, origin_id, destination_id, product_id,
 supplier_id, quantity_tons, distance_km, fuel_cost_inr, freight_cost_inr,
 handling_cost_inr, planned_delivery_date, @actual_delivery_date, @delay_days,
 @demurrage_cost_inr, shipment_status, transport_mode_id)
SET
  actual_delivery_date = NULLIF(@actual_delivery_date, ''),
  delay_days           = NULLIF(@delay_days, ''),
  demurrage_cost_inr    = NULLIF(@demurrage_cost_inr, '');

LOAD DATA LOCAL INFILE 'C:/abc_project/Dataset/Fact_Inventory_Snapshot.csv'
INTO TABLE Fact_Inventory_Snapshot
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(snapshot_date, warehouse_id, product_id, opening_stock_tons, stock_in_tons,
 stock_out_tons, closing_stock_tons, holding_cost_per_ton_inr,
 warehouse_capacity_tons, reorder_point_tons);

-- 3. ANALYSIS QUERIES
-- run each one separately and export the result grid to csv

-- Query 1: inventory turnover by warehouse
SELECT
    w.warehouse_name,
    w.region,
    ROUND(SUM(f.stock_out_tons), 1) AS total_stock_out,
    ROUND(AVG((f.opening_stock_tons + f.closing_stock_tons) / 2), 1) AS avg_inventory,
    ROUND(SUM(f.stock_out_tons) / NULLIF(AVG((f.opening_stock_tons + f.closing_stock_tons) / 2), 0), 2) AS inventory_turnover_ratio
FROM Fact_Inventory_Snapshot f
JOIN Dim_Warehouse w ON f.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name, w.region
ORDER BY inventory_turnover_ratio ASC;


-- Query 2: transport cost per ton-km by mode
SELECT
    tm.mode_name,
    COUNT(*) AS total_shipments,
    ROUND(SUM(s.freight_cost_inr + s.fuel_cost_inr), 0) AS total_transport_cost,
    ROUND(SUM(s.quantity_tons * s.distance_km), 0) AS total_ton_km,
    ROUND(SUM(s.freight_cost_inr + s.fuel_cost_inr) / NULLIF(SUM(s.quantity_tons * s.distance_km), 0), 4) AS cost_per_ton_km
FROM Fact_Shipments s
JOIN Dim_TransportMode tm ON s.transport_mode_id = tm.transport_mode_id
GROUP BY tm.mode_name
ORDER BY cost_per_ton_km DESC;


-- Query 3: average delay by route, ranked worst to best
SELECT
    s.route_id,
    r.distance_km,
    r.terrain_type,
    ROUND(AVG(s.delay_days), 2) AS avg_delay_days,
    COUNT(*) AS shipment_count,
    RANK() OVER (ORDER BY AVG(s.delay_days) DESC) AS delay_rank
FROM Fact_Shipments s
JOIN Dim_Route r ON s.route_id = r.route_id
WHERE s.delay_days IS NOT NULL
GROUP BY s.route_id, r.distance_km, r.terrain_type
ORDER BY avg_delay_days DESC;


-- Query 4: delay by mode, monsoon vs rest of the year
SELECT
    tm.mode_name,
    d.is_monsoon,
    ROUND(AVG(s.delay_days), 2) AS avg_delay_days,
    COUNT(*) AS shipment_count
FROM Fact_Shipments s
JOIN Dim_TransportMode tm ON s.transport_mode_id = tm.transport_mode_id
JOIN Dim_Date d ON s.shipment_date = d.date
WHERE s.delay_days IS NOT NULL
GROUP BY tm.mode_name, d.is_monsoon
ORDER BY tm.mode_name, d.is_monsoon;


-- Query 5: supplier scorecard
WITH supplier_perf AS (
    SELECT
        supplier_id,
        COUNT(*) AS total_shipments,
        ROUND(AVG(delay_days), 2) AS avg_delay,
        ROUND(SUM(demurrage_cost_inr), 0) AS total_penalty_cost,
        ROUND(SUM(freight_cost_inr), 0) AS total_freight_spend
    FROM Fact_Shipments
    WHERE delay_days IS NOT NULL
    GROUP BY supplier_id
)
SELECT
    ds.supplier_name,
    ds.mode_specialization,
    sp.total_shipments,
    sp.avg_delay,
    sp.total_penalty_cost,
    sp.total_freight_spend,
    ROUND(sp.total_penalty_cost / NULLIF(sp.total_freight_spend, 0) * 100, 2) AS penalty_pct_of_spend
FROM supplier_perf sp
JOIN Dim_Supplier ds ON ds.supplier_id = sp.supplier_id
ORDER BY penalty_pct_of_spend DESC;


-- Query 6: warehouse utilization, flagged over/under
SELECT
    w.warehouse_name,
    w.region,
    w.capacity_tons,
    ROUND(AVG(f.closing_stock_tons), 1) AS avg_closing_stock,
    ROUND(AVG(f.closing_stock_tons) / w.capacity_tons * 100, 1) AS avg_utilization_pct,
    CASE
        WHEN AVG(f.closing_stock_tons) / w.capacity_tons > 0.85 THEN 'Over-utilized'
        WHEN AVG(f.closing_stock_tons) / w.capacity_tons < 0.40 THEN 'Under-utilized'
        ELSE 'Healthy'
    END AS utilization_flag
FROM Fact_Inventory_Snapshot f
JOIN Dim_Warehouse w ON f.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name, w.region, w.capacity_tons
ORDER BY avg_utilization_pct DESC;


-- Query 7: pareto - which routes drive most of the freight cost
WITH route_cost AS (
    SELECT route_id, SUM(freight_cost_inr + fuel_cost_inr) AS total_cost
    FROM Fact_Shipments
    GROUP BY route_id
),
ranked AS (
    SELECT
        route_id,
        total_cost,
        SUM(total_cost) OVER (ORDER BY total_cost DESC) AS running_total,
        SUM(total_cost) OVER () AS grand_total
    FROM route_cost
)
SELECT
    route_id,
    ROUND(total_cost, 0) AS total_cost,
    ROUND(running_total / grand_total * 100, 1) AS cumulative_pct_of_total
FROM ranked
ORDER BY total_cost DESC;


-- Query 8: monthly cost trend
SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(s.freight_cost_inr + s.fuel_cost_inr + s.handling_cost_inr + IFNULL(s.demurrage_cost_inr,0)), 0) AS total_logistics_cost,
    ROUND(SUM(s.quantity_tons), 0) AS total_volume_tons,
    ROUND(SUM(s.freight_cost_inr + s.fuel_cost_inr + s.handling_cost_inr + IFNULL(s.demurrage_cost_inr,0)) / NULLIF(SUM(s.quantity_tons),0), 2) AS cost_per_ton
FROM Fact_Shipments s
JOIN Dim_Date d ON s.shipment_date = d.date
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- Query 9: on-time delivery rate by mode
SELECT
    tm.mode_name,
    COUNT(*) AS total_shipments,
    SUM(CASE WHEN s.delay_days = 0 THEN 1 ELSE 0 END) AS on_time_shipments,
    ROUND(SUM(CASE WHEN s.delay_days = 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS on_time_pct
FROM Fact_Shipments s
JOIN Dim_TransportMode tm ON s.transport_mode_id = tm.transport_mode_id
WHERE s.delay_days IS NOT NULL
GROUP BY tm.mode_name
ORDER BY on_time_pct ASC;


-- Query 10: demurrage cost as a share of total transport spend
SELECT
    ROUND(SUM(demurrage_cost_inr), 0) AS total_demurrage_cost,
    ROUND(SUM(freight_cost_inr + fuel_cost_inr), 0) AS total_transport_cost,
    ROUND(SUM(demurrage_cost_inr) / NULLIF(SUM(freight_cost_inr + fuel_cost_inr), 0) * 100, 2) AS demurrage_pct_of_transport_cost
FROM Fact_Shipments
WHERE delay_days IS NOT NULL;


-- Query 11: road shipments that could shift to pipeline where it's available on the same route
SELECT
    s.route_id,
    r.distance_km,
    COUNT(*) AS road_shipments_on_pipeline_capable_routes,
    ROUND(SUM(s.quantity_tons), 0) AS total_tons_shiftable,
    ROUND(SUM(s.freight_cost_inr + s.fuel_cost_inr), 0) AS current_road_cost,
    ROUND(SUM(s.quantity_tons * r.distance_km) *
          (SELECT base_cost_per_ton_km FROM Dim_TransportMode WHERE mode_name = 'Pipeline') / 100, 0)
          AS estimated_cost_if_pipeline
FROM Fact_Shipments s
JOIN Dim_Route r ON s.route_id = r.route_id
JOIN Dim_TransportMode tm ON s.transport_mode_id = tm.transport_mode_id
WHERE tm.mode_name = 'Road'
  AND r.available_modes LIKE '%Pipeline%'
GROUP BY s.route_id, r.distance_km
ORDER BY current_road_cost DESC;
