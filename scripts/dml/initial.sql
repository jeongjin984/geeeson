/* =========================================================
   TEST DATA SCRIPT
   대상:
   - product_db
   - inventory_db
   - order_db
   - payment_db

   전제:
   - 각 DDL이 먼저 생성되어 있어야 함
   - MySQL 8.x 기준
   ========================================================= */


/* =========================================================
   1) PRODUCT DOMAIN
   ========================================================= */
USE product_db;

SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM product_event;
DELETE FROM product_price_history;
DELETE FROM product_sku_option_map;
DELETE FROM product_option_value;
DELETE FROM product_option;
DELETE FROM product_sku;
DELETE FROM product;
DELETE FROM category;
DELETE FROM brand;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Brand
INSERT INTO brand (
    brand_code, brand_name, brand_status, attributes_json
) VALUES
      ('BRD-NIKE',   'NIKE',   'ACTIVE', JSON_OBJECT('origin', 'US')),
      ('BRD-APPLE',  'APPLE',  'ACTIVE', JSON_OBJECT('origin', 'US')),
      ('BRD-LOGI',   'LOGITECH', 'ACTIVE', JSON_OBJECT('origin', 'CH'));

-- 2. Category
INSERT INTO category (
    category_code, category_name, parent_category_code, category_level, sort_order, category_status, attributes_json
) VALUES
      ('CAT-FASHION',      'Fashion',       NULL,            1, 1, 'ACTIVE', NULL),
      ('CAT-TOP',          'Top',           'CAT-FASHION',   2, 1, 'ACTIVE', NULL),
      ('CAT-ELECTRONICS',  'Electronics',   NULL,            1, 2, 'ACTIVE', NULL),
      ('CAT-PHONE',        'Phone',         'CAT-ELECTRONICS', 2, 1, 'ACTIVE', NULL),
      ('CAT-ACCESSORY',    'Accessory',     'CAT-ELECTRONICS', 2, 2, 'ACTIVE', NULL);

-- 3. Product
INSERT INTO product (
    product_code, product_name, product_type, product_status,
    brand_code, category_code, product_description,
    sell_start_at, sell_end_at, taxable_yn, adult_only_yn, attributes_json
) VALUES
      ('PRD-TSHIRT-001', 'Dry T-Shirt', 'NORMAL', 'ACTIVE',
       'BRD-NIKE', 'CAT-TOP', 'Basic dry-fit T-shirt',
       '2025-01-01 00:00:00', NULL, 1, 0, JSON_OBJECT('season', 'ALL')),
      ('PRD-PHONE-001', 'iPhone 16', 'NORMAL', 'ACTIVE',
       'BRD-APPLE', 'CAT-PHONE', 'Smartphone flagship model',
       '2025-09-01 00:00:00', NULL, 1, 0, JSON_OBJECT('network', '5G')),
      ('PRD-MOUSE-001', 'Wireless Mouse M650', 'NORMAL', 'ACTIVE',
       'BRD-LOGI', 'CAT-ACCESSORY', 'Wireless office mouse',
       '2025-01-01 00:00:00', NULL, 1, 0, JSON_OBJECT('connectivity', 'BT'));

-- 4. Product SKU
INSERT INTO product_sku (
    product_code, sku_code, sku_name, sku_status, barcode, option_summary,
    uom, unit_weight, unit_volume, sale_price, cost_price, currency_code,
    sellable_yn, returnable_yn, effective_from, effective_to, attributes_json
) VALUES
      ('PRD-TSHIRT-001', 'SKU-TSHIRT-BLK-M', 'Dry T-Shirt / Black / M', 'ACTIVE', '880000000001', 'COLOR=BLACK;SIZE=M',
       'EA', 0.2500, 0.002500, 29000, 14000, 'KRW', 1, 1, '2025-01-01 00:00:00', NULL, NULL),
      ('PRD-TSHIRT-001', 'SKU-TSHIRT-BLK-L', 'Dry T-Shirt / Black / L', 'ACTIVE', '880000000002', 'COLOR=BLACK;SIZE=L',
       'EA', 0.2700, 0.002700, 29000, 14500, 'KRW', 1, 1, '2025-01-01 00:00:00', NULL, NULL),
      ('PRD-PHONE-001', 'SKU-PHONE-BLK-128', 'iPhone 16 / Black / 128GB', 'ACTIVE', '880000000101', 'COLOR=BLACK;STORAGE=128GB',
       'EA', 0.2200, 0.001200, 1350000, 980000, 'KRW', 1, 1, '2025-09-01 00:00:00', NULL, NULL),
      ('PRD-MOUSE-001', 'SKU-MOUSE-WHT', 'Wireless Mouse M650 / White', 'ACTIVE', '880000000201', 'COLOR=WHITE',
       'EA', 0.1200, 0.001000, 45000, 22000, 'KRW', 1, 1, '2025-01-01 00:00:00', NULL, NULL);

-- 5. Product Option Definition
INSERT INTO product_option (
    product_code, option_code, option_name, option_type, required_yn, sort_order, attributes_json
) VALUES
      ('PRD-TSHIRT-001', 'COLOR',   'Color',   'SELECT', 1, 1, NULL),
      ('PRD-TSHIRT-001', 'SIZE',    'Size',    'SELECT', 1, 2, NULL),
      ('PRD-PHONE-001',  'COLOR',   'Color',   'SELECT', 1, 1, NULL),
      ('PRD-PHONE-001',  'STORAGE', 'Storage', 'SELECT', 1, 2, NULL),
      ('PRD-MOUSE-001',  'COLOR',   'Color',   'SELECT', 1, 1, NULL);

-- 6. Product Option Value
INSERT INTO product_option_value (
    product_code, option_code, option_value_code, option_value_name, sort_order, attributes_json
) VALUES
      ('PRD-TSHIRT-001', 'COLOR',   'BLACK', 'Black', 1, NULL),
      ('PRD-TSHIRT-001', 'SIZE',    'M',     'Medium', 1, NULL),
      ('PRD-TSHIRT-001', 'SIZE',    'L',     'Large', 2, NULL),
      ('PRD-PHONE-001',  'COLOR',   'BLACK', 'Black', 1, NULL),
      ('PRD-PHONE-001',  'STORAGE', '128GB', '128GB', 1, NULL),
      ('PRD-MOUSE-001',  'COLOR',   'WHITE', 'White', 1, NULL);

-- 7. SKU Option Mapping
INSERT INTO product_sku_option_map (sku_code, option_code, option_value_code) VALUES
                                                                                  ('SKU-TSHIRT-BLK-M', 'COLOR', 'BLACK'),
                                                                                  ('SKU-TSHIRT-BLK-M', 'SIZE',  'M'),
                                                                                  ('SKU-TSHIRT-BLK-L', 'COLOR', 'BLACK'),
                                                                                  ('SKU-TSHIRT-BLK-L', 'SIZE',  'L'),
                                                                                  ('SKU-PHONE-BLK-128', 'COLOR', 'BLACK'),
                                                                                  ('SKU-PHONE-BLK-128', 'STORAGE', '128GB'),
                                                                                  ('SKU-MOUSE-WHT', 'COLOR', 'WHITE');

-- 8. Product Price History
INSERT INTO product_price_history (
    sku_code, price_type, currency_code, price_amount, effective_from, effective_to, reason_code, attributes_json
) VALUES
      ('SKU-TSHIRT-BLK-M', 'SALE', 'KRW', 32000, '2025-01-01 00:00:00', '2025-06-30 23:59:59', 'INITIAL', NULL),
      ('SKU-TSHIRT-BLK-M', 'SALE', 'KRW', 29000, '2025-07-01 00:00:00', NULL, 'PROMO_STABLE', NULL),
      ('SKU-TSHIRT-BLK-L', 'SALE', 'KRW', 29000, '2025-01-01 00:00:00', NULL, 'INITIAL', NULL),
      ('SKU-PHONE-BLK-128', 'SALE', 'KRW', 1390000, '2025-09-01 00:00:00', '2025-12-31 23:59:59', 'LAUNCH', NULL),
      ('SKU-PHONE-BLK-128', 'SALE', 'KRW', 1350000, '2026-01-01 00:00:00', NULL, 'PRICE_ADJUST', NULL),
      ('SKU-MOUSE-WHT', 'SALE', 'KRW', 45000, '2025-01-01 00:00:00', NULL, 'INITIAL', NULL);

-- 9. Product Event
INSERT INTO product_event (
    product_code, sku_code, event_type, event_status, event_id, event_at, actor_type, actor_id, message, attributes_json
) VALUES
      ('PRD-TSHIRT-001', NULL, 'PRODUCT_CREATED', 'SUCCESS', 'PEVT-1001', '2025-01-01 09:00:00', 'SYSTEM', 'seed', 'T-shirt product created', NULL),
      ('PRD-TSHIRT-001', 'SKU-TSHIRT-BLK-M', 'SKU_ACTIVATED', 'SUCCESS', 'PEVT-1002', '2025-01-01 09:10:00', 'SYSTEM', 'seed', 'SKU activated', NULL),
      ('PRD-PHONE-001', 'SKU-PHONE-BLK-128', 'PRICE_CHANGED', 'SUCCESS', 'PEVT-1003', '2026-01-01 00:00:00', 'SYSTEM', 'pricing-batch', 'Launch discount applied', NULL),
      ('PRD-MOUSE-001', 'SKU-MOUSE-WHT', 'SKU_ACTIVATED', 'SUCCESS', 'PEVT-1004', '2025-01-01 10:00:00', 'SYSTEM', 'seed', 'Mouse SKU activated', NULL);



/* =========================================================
   2) INVENTORY DOMAIN
   ========================================================= */
USE inventory_db;

SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM inventory_snapshot;
DELETE FROM inventory_transaction;
DELETE FROM inventory_reservation;
DELETE FROM inventory_stock;
DELETE FROM item_lot;
DELETE FROM item;
DELETE FROM location;
DELETE FROM zone;
DELETE FROM warehouse;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Warehouse
INSERT INTO warehouse (
    warehouse_code, warehouse_name, country_code, timezone_name, is_active
) VALUES
      ('FC-SEOUL', 'Seoul Fulfillment Center', 'KR', 'Asia/Seoul', 1),
      ('FC-BUSAN', 'Busan Fulfillment Center', 'KR', 'Asia/Seoul', 1);

-- 2. Zone
INSERT INTO zone (
    warehouse_id, zone_code, zone_name, temperature_type, is_active
)
SELECT warehouse_id, 'AMBIENT', 'Ambient Zone', 'AMBIENT', 1
FROM warehouse WHERE warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT warehouse_id, 'QC', 'Quality Check Zone', 'AMBIENT', 1
FROM warehouse WHERE warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT warehouse_id, 'AMBIENT', 'Ambient Zone', 'AMBIENT', 1
FROM warehouse WHERE warehouse_code = 'FC-BUSAN';

-- 3. Location
INSERT INTO location (
    warehouse_id, zone_id, location_code, location_type,
    aisle, rack, `level`, bin,
    capacity_unit_qty, capacity_volume, capacity_weight,
    x_coord, y_coord, z_coord,
    is_pickable, is_active
)
SELECT w.warehouse_id, z.zone_id, 'RCV-01', 'RECEIVING',
       'R', '01', '1', '01',
       1000, 50, 1000,
       1, 1, 1,
       0, 1
FROM warehouse w
         JOIN zone z ON z.warehouse_id = w.warehouse_id AND z.zone_code = 'AMBIENT'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT w.warehouse_id, z.zone_id, 'STO-A-01-01', 'STORAGE',
       'A', '01', '1', '01',
       500, 20, 500,
       10, 1, 1,
       0, 1
FROM warehouse w
         JOIN zone z ON z.warehouse_id = w.warehouse_id AND z.zone_code = 'AMBIENT'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT w.warehouse_id, z.zone_id, 'PCK-A-01-01', 'PICKING',
       'A', 'P1', '1', '01',
       200, 10, 200,
       15, 1, 1,
       1, 1
FROM warehouse w
         JOIN zone z ON z.warehouse_id = w.warehouse_id AND z.zone_code = 'AMBIENT'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT w.warehouse_id, z.zone_id, 'QC-01', 'QC',
       'Q', '01', '1', '01',
       100, 5, 100,
       20, 1, 1,
       0, 1
FROM warehouse w
         JOIN zone z ON z.warehouse_id = w.warehouse_id AND z.zone_code = 'QC'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT w.warehouse_id, z.zone_id, 'STO-B-01-01', 'STORAGE',
       'B', '01', '1', '01',
       400, 15, 400,
       5, 1, 1,
       0, 1
FROM warehouse w
         JOIN zone z ON z.warehouse_id = w.warehouse_id AND z.zone_code = 'AMBIENT'
WHERE w.warehouse_code = 'FC-BUSAN';

-- 4. Item
-- product_sku.sku_code와 동일한 코드 사용
INSERT INTO item (
    item_code, item_name, item_description, uom,
    unit_weight, unit_volume, shelf_life_days,
    lot_controlled, serial_controlled, abc_class, is_active
) VALUES
      ('SKU-TSHIRT-BLK-M',   'Dry T-Shirt / Black / M',        'Linked logically to product SKU', 'EA', 0.2500, 0.002500, NULL, 0, 0, 'A', 1),
      ('SKU-TSHIRT-BLK-L',   'Dry T-Shirt / Black / L',        'Linked logically to product SKU', 'EA', 0.2700, 0.002700, NULL, 0, 0, 'A', 1),
      ('SKU-PHONE-BLK-128',  'iPhone 16 / Black / 128GB',      'Serialized / lot-controlled sample', 'EA', 0.2200, 0.001200, NULL, 1, 1, 'A', 1),
      ('SKU-MOUSE-WHT',      'Wireless Mouse M650 / White',    'Linked logically to product SKU', 'EA', 0.1200, 0.001000, NULL, 0, 0, 'B', 1);

-- 5. Item Lot
INSERT INTO item_lot (
    item_id, lot_no, manufacture_date, expiry_date, vendor_lot_no, attributes_json
)
SELECT item_id, 'LOT-PHONE-250901-A', '2025-09-01', NULL, 'APL-LOT-001', JSON_OBJECT('factory', 'CN-SZ')
FROM item WHERE item_code = 'SKU-PHONE-BLK-128'
UNION ALL
SELECT item_id, 'LOT-PHONE-251001-B', '2025-10-01', NULL, 'APL-LOT-002', JSON_OBJECT('factory', 'CN-SZ')
FROM item WHERE item_code = 'SKU-PHONE-BLK-128';

-- 6. Current Inventory Stock
INSERT INTO inventory_stock (
    batch_job_execution_id, warehouse_id, location_id, item_id, lot_id, stock_status,
    on_hand_qty, allocated_qty, picked_qty, available_qty,
    last_transaction_at
)
SELECT
    9001,
    w.warehouse_id,
    l.location_id,
    i.item_id,
    NULL,
    'AVAILABLE',
    120, 10, 0, 110,
    '2026-03-25 09:00:00'
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'PCK-A-01-01'
         JOIN item i ON i.item_code = 'SKU-TSHIRT-BLK-M'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT
    9001,
    w.warehouse_id,
    l.location_id,
    i.item_id,
    NULL,
    'AVAILABLE',
    80, 0, 0, 80,
    '2026-03-25 09:05:00'
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'STO-A-01-01'
         JOIN item i ON i.item_code = 'SKU-TSHIRT-BLK-L'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT
    9001,
    w.warehouse_id,
    l.location_id,
    i.item_id,
    il.lot_id,
    'AVAILABLE',
    15, 2, 0, 13,
    '2026-03-25 09:10:00'
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'STO-A-01-01'
         JOIN item i ON i.item_code = 'SKU-PHONE-BLK-128'
         JOIN item_lot il ON il.item_id = i.item_id AND il.lot_no = 'LOT-PHONE-250901-A'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT
    9001,
    w.warehouse_id,
    l.location_id,
    i.item_id,
    il.lot_id,
    'AVAILABLE',
    8, 0, 0, 8,
    '2026-03-25 09:12:00'
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'STO-B-01-01'
         JOIN item i ON i.item_code = 'SKU-PHONE-BLK-128'
         JOIN item_lot il ON il.item_id = i.item_id AND il.lot_no = 'LOT-PHONE-251001-B'
WHERE w.warehouse_code = 'FC-BUSAN'
UNION ALL
SELECT
    9001,
    w.warehouse_id,
    l.location_id,
    i.item_id,
    NULL,
    'AVAILABLE',
    60, 5, 0, 55,
    '2026-03-25 09:15:00'
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'PCK-A-01-01'
         JOIN item i ON i.item_code = 'SKU-MOUSE-WHT'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT
    9001,
    w.warehouse_id,
    l.location_id,
    i.item_id,
    il.lot_id,
    'QUARANTINE',
    1, 0, 0, 0,
    '2026-03-25 09:20:00'
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'QC-01'
         JOIN item i ON i.item_code = 'SKU-PHONE-BLK-128'
         JOIN item_lot il ON il.item_id = i.item_id AND il.lot_no = 'LOT-PHONE-250901-A'
WHERE w.warehouse_code = 'FC-SEOUL';

-- 7. Reservation
INSERT INTO inventory_reservation (
    batch_job_execution_id, warehouse_id, location_id, item_id, lot_id,
    reference_type, reference_no, reference_line_no,
    reserved_qty, released_qty, reservation_status,
    reserved_at, expires_at
)
SELECT
    9002, w.warehouse_id, l.location_id, i.item_id, NULL,
    'OUTBOUND_ORDER', 'ORD-20260326-0001', '1',
    2, 0, 'ACTIVE',
    '2026-03-26 08:00:00', '2026-03-27 08:00:00'
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'PCK-A-01-01'
         JOIN item i ON i.item_code = 'SKU-TSHIRT-BLK-M'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT
    9002, w.warehouse_id, l.location_id, i.item_id, il.lot_id,
    'OUTBOUND_ORDER', 'ORD-20260326-0001', '2',
    1, 0, 'ACTIVE',
    '2026-03-26 08:01:00', '2026-03-27 08:01:00'
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'STO-A-01-01'
         JOIN item i ON i.item_code = 'SKU-PHONE-BLK-128'
         JOIN item_lot il ON il.item_id = i.item_id AND il.lot_no = 'LOT-PHONE-250901-A'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT
    9002, w.warehouse_id, l.location_id, i.item_id, NULL,
    'OUTBOUND_ORDER', 'ORD-20260326-0002', '1',
    5, 2, 'PARTIALLY_RELEASED',
    '2026-03-26 08:10:00', '2026-03-27 08:10:00'
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'PCK-A-01-01'
         JOIN item i ON i.item_code = 'SKU-MOUSE-WHT'
WHERE w.warehouse_code = 'FC-SEOUL';

-- 8. Inventory Transaction
INSERT INTO inventory_transaction (
    batch_job_execution_id, transaction_type, reference_type, reference_no, reference_line_no, event_id,
    warehouse_id, from_location_id, to_location_id,
    item_id, lot_id,
    stock_status_before, stock_status_after,
    quantity, uom,
    on_hand_before, on_hand_after,
    allocated_before, allocated_after,
    available_before, available_after,
    transaction_at, created_by, remark, attributes_json
)
SELECT
    9101, 'ALLOCATE', 'OUTBOUND_ORDER', 'ORD-20260326-0001', '1', 'IEVT-10001',
    w.warehouse_id, l.location_id, NULL,
    i.item_id, NULL,
    'AVAILABLE', 'RESERVED',
    2, 'EA',
    120, 120,
    8, 10,
    112, 110,
    '2026-03-26 08:00:00', 'allocator', 'Allocate t-shirt', NULL
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'PCK-A-01-01'
         JOIN item i ON i.item_code = 'SKU-TSHIRT-BLK-M'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT
    9101, 'ALLOCATE', 'OUTBOUND_ORDER', 'ORD-20260326-0001', '2', 'IEVT-10002',
    w.warehouse_id, l.location_id, NULL,
    i.item_id, il.lot_id,
    'AVAILABLE', 'RESERVED',
    1, 'EA',
    15, 15,
    1, 2,
    14, 13,
    '2026-03-26 08:01:00', 'allocator', 'Allocate phone', JSON_OBJECT('lot_no', 'LOT-PHONE-250901-A')
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'STO-A-01-01'
         JOIN item i ON i.item_code = 'SKU-PHONE-BLK-128'
         JOIN item_lot il ON il.item_id = i.item_id AND il.lot_no = 'LOT-PHONE-250901-A'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT
    9102, 'PICK', 'OUTBOUND_ORDER', 'ORD-20260326-0001', '1', 'IEVT-10003',
    w.warehouse_id, l.location_id, NULL,
    i.item_id, NULL,
    'RESERVED', 'PICKED',
    2, 'EA',
    120, 120,
    10, 10,
    110, 110,
    '2026-03-26 09:00:00', 'picker01', 'Picked t-shirt', NULL
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'PCK-A-01-01'
         JOIN item i ON i.item_code = 'SKU-TSHIRT-BLK-M'
WHERE w.warehouse_code = 'FC-SEOUL'
UNION ALL
SELECT
    9103, 'SHIP', 'OUTBOUND_ORDER', 'ORD-20260326-0001', '1', 'IEVT-10004',
    w.warehouse_id, l.location_id, NULL,
    i.item_id, NULL,
    'PICKED', 'AVAILABLE',
    2, 'EA',
    120, 118,
    10, 8,
    110, 110,
    '2026-03-26 10:00:00', 'shipper01', 'Shipped t-shirt', NULL
FROM warehouse w
         JOIN location l ON l.warehouse_id = w.warehouse_id AND l.location_code = 'PCK-A-01-01'
         JOIN item i ON i.item_code = 'SKU-TSHIRT-BLK-M'
WHERE w.warehouse_code = 'FC-SEOUL';

-- 9. Inventory Snapshot
INSERT INTO inventory_snapshot (
    batch_job_execution_id, snapshot_at,
    warehouse_id, location_id, item_id, lot_id, stock_status,
    on_hand_qty, allocated_qty, picked_qty, available_qty
)
SELECT
    9201, '2026-03-26 00:00:00',
    warehouse_id, location_id, item_id, lot_id, stock_status,
    on_hand_qty, allocated_qty, picked_qty, available_qty
FROM inventory_stock;



/* =========================================================
   3) ORDER DOMAIN
   ========================================================= */
USE order_db;

SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM order_event;
DELETE FROM shipment_line;
DELETE FROM shipment;
DELETE FROM outbound_order_fulfillment;
DELETE FROM outbound_order_line;
DELETE FROM outbound_order;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Outbound Order Header
INSERT INTO outbound_order (
    batch_job_execution_id,
    order_no, external_order_no, order_type, order_status,
    fulfillment_center_code,
    customer_code, customer_name,
    priority, requested_ship_at, promised_delivery_at,
    ordered_at, released_at, allocated_at, shipped_at, cancelled_at,
    recipient_name, recipient_phone, recipient_zip_code,
    recipient_address1, recipient_address2, recipient_city, recipient_state, recipient_country_code,
    delivery_instruction, carrier_code, service_level,
    total_order_qty, total_allocated_qty, total_shipped_qty,
    attributes_json
) VALUES
      (
          10001,
          'ORD-20260326-0001', 'EXT-ORD-A-1001', 'NORMAL', 'PARTIALLY_SHIPPED',
          'FC-SEOUL',
          'CUST-100', 'Kim Minsu',
          1, '2026-03-26 12:00:00', '2026-03-27 18:00:00',
          '2026-03-26 07:30:00', '2026-03-26 07:40:00', '2026-03-26 08:05:00', '2026-03-26 10:00:00', NULL,
          'Kim Minsu', '010-1111-2222', '06236',
          'Seoul Gangnam-daero 1', '101-1201', 'Seoul', 'Seoul', 'KR',
          'Leave at door', 'CJLOG', 'NEXT_DAY',
          3, 3, 2,
          JSON_OBJECT('channel', 'APP')
      ),
      (
          10001,
          'ORD-20260326-0002', 'EXT-ORD-A-1002', 'NORMAL', 'PARTIALLY_ALLOCATED',
          'FC-SEOUL',
          'CUST-200', 'Lee Jiyoung',
          3, '2026-03-26 15:00:00', '2026-03-28 18:00:00',
          '2026-03-26 08:00:00', '2026-03-26 08:05:00', '2026-03-26 08:15:00', NULL, NULL,
          'Lee Jiyoung', '010-3333-4444', '48058',
          'Busan Centum-ro 20', '202-903', 'Busan', 'Busan', 'KR',
          'Call before delivery', 'HANJIN', 'STANDARD',
          6, 3, 0,
          JSON_OBJECT('channel', 'WEB')
      ),
      (
          10001,
          'ORD-20260326-0003', 'EXT-ORD-A-1003', 'SIMULATION', 'CANCELLED',
          'FC-BUSAN',
          'CUST-300', 'Park Junho',
          9, '2026-03-27 09:00:00', '2026-03-29 18:00:00',
          '2026-03-26 09:00:00', NULL, NULL, NULL, '2026-03-26 09:10:00',
          'Park Junho', '010-5555-6666', '21984',
          'Incheon Tower-daero 99', NULL, 'Incheon', 'Incheon', 'KR',
          NULL, NULL, NULL,
          1, 0, 0,
          JSON_OBJECT('reason', 'simulation cancelled')
      );

-- 2. Outbound Order Line
INSERT INTO outbound_order_line (
    outbound_order_id, line_no, line_status,
    sku_code, sku_name,
    ordered_qty, allocated_qty, picked_qty, packed_qty, shipped_qty, cancelled_qty,
    uom, requested_lot_no, lot_strict_yn,
    requested_ship_at, allocated_at, picked_at, packed_at, shipped_at, cancelled_at,
    unit_price, attributes_json
)
SELECT
    o.outbound_order_id, 1, 'SHIPPED',
    'SKU-TSHIRT-BLK-M', 'Dry T-Shirt / Black / M',
    2, 2, 2, 2, 2, 0,
    'EA', NULL, 0,
    '2026-03-26 12:00:00', '2026-03-26 08:00:00', '2026-03-26 09:00:00', '2026-03-26 09:30:00', '2026-03-26 10:00:00', NULL,
    29000, NULL
FROM outbound_order o
WHERE o.order_no = 'ORD-20260326-0001'
UNION ALL
SELECT
    o.outbound_order_id, 2, 'ALLOCATED',
    'SKU-PHONE-BLK-128', 'iPhone 16 / Black / 128GB',
    1, 1, 0, 0, 0, 0,
    'EA', 'LOT-PHONE-250901-A', 1,
    '2026-03-26 12:00:00', '2026-03-26 08:01:00', NULL, NULL, NULL, NULL,
    1350000, JSON_OBJECT('gift_wrap', false)
FROM outbound_order o
WHERE o.order_no = 'ORD-20260326-0001'
UNION ALL
SELECT
    o.outbound_order_id, 1, 'PARTIALLY_ALLOCATED',
    'SKU-MOUSE-WHT', 'Wireless Mouse M650 / White',
    5, 3, 0, 0, 0, 0,
    'EA', NULL, 0,
    '2026-03-26 15:00:00', '2026-03-26 08:15:00', NULL, NULL, NULL, NULL,
    45000, NULL
FROM outbound_order o
WHERE o.order_no = 'ORD-20260326-0002'
UNION ALL
SELECT
    o.outbound_order_id, 1, 'CANCELLED',
    'SKU-TSHIRT-BLK-L', 'Dry T-Shirt / Black / L',
    1, 0, 0, 0, 0, 1,
    'EA', NULL, 0,
    '2026-03-27 09:00:00', NULL, NULL, NULL, NULL, '2026-03-26 09:10:00',
    29000, NULL
FROM outbound_order o
WHERE o.order_no = 'ORD-20260326-0003';

-- 3. Order Fulfillment Result
INSERT INTO outbound_order_fulfillment (
    batch_job_execution_id,
    order_no, order_line_no, fulfillment_status,
    fulfillment_ref_no, reservation_ref_no,
    allocated_qty, picked_qty, shipped_qty,
    allocated_at, picked_at, shipped_at,
    message, attributes_json
) VALUES
      (10002, 'ORD-20260326-0001', 1, 'SHIPPED', 'FUL-0001', 'ORD-20260326-0001-1', 2, 2, 2,
       '2026-03-26 08:00:00', '2026-03-26 09:00:00', '2026-03-26 10:00:00',
       'Completed shipment', NULL),
      (10002, 'ORD-20260326-0001', 2, 'ALLOCATED', 'FUL-0002', 'ORD-20260326-0001-2', 1, 0, 0,
       '2026-03-26 08:01:00', NULL, NULL,
       'Allocated by requested lot', JSON_OBJECT('requested_lot_no', 'LOT-PHONE-250901-A')),
      (10002, 'ORD-20260326-0002', 1, 'PARTIALLY_ALLOCATED', 'FUL-0003', 'ORD-20260326-0002-1', 3, 0, 0,
       '2026-03-26 08:15:00', NULL, NULL,
       'Insufficient immediately pickable stock', NULL),
      (10002, 'ORD-20260326-0003', 1, 'CANCELLED', 'FUL-0004', NULL, 0, 0, 0,
       NULL, NULL, NULL,
       'Simulation order cancelled', NULL);

-- 4. Shipment Header
INSERT INTO shipment (
    batch_job_execution_id,
    shipment_no, shipment_status,
    order_no, fulfillment_center_code,
    carrier_code, service_level, tracking_no,
    shipped_at, delivered_at,
    total_shipment_qty, total_package_count, total_weight, total_volume,
    attributes_json
) VALUES
    (
        10003,
        'SHP-20260326-0001', 'SHIPPED',
        'ORD-20260326-0001', 'FC-SEOUL',
        'CJLOG', 'NEXT_DAY', 'CJ202603260001',
        '2026-03-26 10:00:00', NULL,
        2, 1, 0.5000, 0.0050,
        JSON_OBJECT('box_type', 'SMALL')
    );

-- 5. Shipment Line
INSERT INTO shipment_line (
    shipment_id, order_no, order_line_no, line_no,
    sku_code, sku_name, lot_no,
    shipped_qty, uom, from_location_code,
    packed_at, shipped_at, attributes_json
)
SELECT
    s.shipment_id, 'ORD-20260326-0001', 1, 1,
    'SKU-TSHIRT-BLK-M', 'Dry T-Shirt / Black / M', NULL,
    2, 'EA', 'PCK-A-01-01',
    '2026-03-26 09:30:00', '2026-03-26 10:00:00', NULL
FROM shipment s
WHERE s.shipment_no = 'SHP-20260326-0001';

-- 6. Order Event
INSERT INTO order_event (
    batch_job_execution_id,
    order_no, order_line_no, shipment_no,
    event_type, event_status, event_id,
    event_at, actor_type, actor_id,
    message, attributes_json
) VALUES
      (10004, 'ORD-20260326-0001', NULL, NULL, 'ORDER_CREATED', 'SUCCESS', 'OEVT-1001',
       '2026-03-26 07:30:00', 'SYSTEM', 'order-api', 'Order created', NULL),
      (10004, 'ORD-20260326-0001', 1, NULL, 'LINE_ALLOCATED', 'SUCCESS', 'OEVT-1002',
       '2026-03-26 08:00:00', 'SYSTEM', 'allocator', 'Line 1 allocated', NULL),
      (10004, 'ORD-20260326-0001', 1, NULL, 'LINE_PICKED', 'SUCCESS', 'OEVT-1003',
       '2026-03-26 09:00:00', 'USER', 'picker01', 'Line 1 picked', NULL),
      (10004, 'ORD-20260326-0001', 1, 'SHP-20260326-0001', 'LINE_SHIPPED', 'SUCCESS', 'OEVT-1004',
       '2026-03-26 10:00:00', 'USER', 'shipper01', 'Line 1 shipped', NULL),
      (10004, 'ORD-20260326-0002', 1, NULL, 'PARTIAL_ALLOCATION', 'WARN', 'OEVT-1005',
       '2026-03-26 08:15:00', 'SYSTEM', 'allocator', 'Only partial quantity allocated', NULL),
      (10004, 'ORD-20260326-0003', 1, NULL, 'ORDER_CANCELLED', 'SUCCESS', 'OEVT-1006',
       '2026-03-26 09:10:00', 'SYSTEM', 'simulation-batch', 'Simulation order cancelled', NULL);



/* =========================================================
   4) PAYMENT DOMAIN
   ========================================================= */
USE payment_db;

SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM payment_event;
DELETE FROM refund_allocation;
DELETE FROM refund;
DELETE FROM payment_allocation;
DELETE FROM payment_transaction;
DELETE FROM payment_method;
DELETE FROM payment;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Payment Header
INSERT INTO payment (
    batch_job_execution_id,
    payment_no, order_no,
    payment_type, payment_status,
    payer_id, payer_name,
    currency_code, order_amount, paid_amount, cancelled_amount, refunded_amount, remaining_amount,
    requested_at, authorized_at, captured_at, cancelled_at, refunded_at, failed_at, expired_at,
    failure_code, failure_message, attributes_json
) VALUES
      (
          11001,
          'PAY-20260326-0001', 'ORD-20260326-0001',
          'SALE', 'CAPTURED',
          'USR-100', 'Kim Minsu',
          'KRW', 1408000, 1408000, 0, 0, 0,
          '2026-03-26 07:31:00', '2026-03-26 07:31:10', '2026-03-26 07:31:20', NULL, NULL, NULL, NULL,
          NULL, NULL, JSON_OBJECT('pg', 'TOSS')
      ),
      (
          11001,
          'PAY-20260326-0002', 'ORD-20260326-0002',
          'SALE', 'PARTIALLY_REFUNDED',
          'USR-200', 'Lee Jiyoung',
          'KRW', 225000, 225000, 0, 90000, 0,
          '2026-03-26 08:01:00', '2026-03-26 08:01:08', '2026-03-26 08:01:15', NULL, '2026-03-26 11:00:00', NULL, NULL,
          NULL, NULL, JSON_OBJECT('pg', 'KCP')
      ),
      (
          11001,
          'PAY-20260326-0003', 'ORD-20260326-0003',
          'MANUAL', 'CANCELLED',
          'USR-300', 'Park Junho',
          'KRW', 29000, 0, 29000, 0, 0,
          '2026-03-26 09:00:00', NULL, NULL, '2026-03-26 09:11:00', NULL, NULL, NULL,
          NULL, NULL, JSON_OBJECT('reason', 'simulation cancel')
      );

-- 2. Payment Method
INSERT INTO payment_method (
    payment_no, payment_method_type, payment_method_status,
    method_seq, provider_code, provider_method_code,
    amount, currency_code,
    card_bin, card_last4, card_issuer_name, approval_no,
    bank_code, bank_account_masked, virtual_account_no_masked, virtual_account_due_at,
    point_type_code, attributes_json
) VALUES
      ('PAY-20260326-0001', 'CARD', 'USED', 1, 'TOSS', 'CARD', 1408000, 'KRW',
       '356123', '1234', 'KB Card', 'APR-0001',
       NULL, NULL, NULL, NULL, NULL, NULL),
      ('PAY-20260326-0002', 'CARD', 'USED', 1, 'KCP', 'CARD', 180000, 'KRW',
       '512345', '4321', 'Shinhan Card', 'APR-0002',
       NULL, NULL, NULL, NULL, NULL, NULL),
      ('PAY-20260326-0002', 'POINT', 'USED', 2, NULL, NULL, 45000, 'KRW',
       NULL, NULL, NULL, NULL,
       NULL, NULL, NULL, NULL, 'SHOP_POINT', NULL),
      ('PAY-20260326-0003', 'MANUAL', 'CANCELLED', 1, NULL, NULL, 29000, 'KRW',
       NULL, NULL, NULL, NULL,
       NULL, NULL, NULL, NULL, NULL, NULL);

-- 3. Payment Transaction
INSERT INTO payment_transaction (
    batch_job_execution_id,
    payment_no, payment_txn_no, parent_payment_txn_no,
    transaction_type, transaction_status,
    payment_method_type, provider_code, provider_txn_id, provider_order_id,
    currency_code, transaction_amount,
    requested_at, processed_at,
    failure_code, failure_message,
    idempotency_key, event_id, attributes_json
) VALUES
      (11002, 'PAY-20260326-0001', 'PTXN-0001', NULL,
       'AUTHORIZE', 'SUCCESS',
       'CARD', 'TOSS', 'TOSS-TXN-0001', 'TOSS-ORD-0001',
       'KRW', 1408000,
       '2026-03-26 07:31:00', '2026-03-26 07:31:10',
       NULL, NULL,
       'idem-pay-1-auth', 'PEV-2001', NULL),
      (11002, 'PAY-20260326-0001', 'PTXN-0002', 'PTXN-0001',
       'CAPTURE', 'SUCCESS',
       'CARD', 'TOSS', 'TOSS-TXN-0002', 'TOSS-ORD-0001',
       'KRW', 1408000,
       '2026-03-26 07:31:11', '2026-03-26 07:31:20',
       NULL, NULL,
       'idem-pay-1-cap', 'PEV-2002', NULL),

      (11002, 'PAY-20260326-0002', 'PTXN-0003', NULL,
       'AUTHORIZE', 'SUCCESS',
       'CARD', 'KCP', 'KCP-TXN-0003', 'KCP-ORD-0002',
       'KRW', 225000,
       '2026-03-26 08:01:00', '2026-03-26 08:01:08',
       NULL, NULL,
       'idem-pay-2-auth', 'PEV-2003', NULL),
      (11002, 'PAY-20260326-0002', 'PTXN-0004', 'PTXN-0003',
       'CAPTURE', 'SUCCESS',
       'CARD', 'KCP', 'KCP-TXN-0004', 'KCP-ORD-0002',
       'KRW', 225000,
       '2026-03-26 08:01:09', '2026-03-26 08:01:15',
       NULL, NULL,
       'idem-pay-2-cap', 'PEV-2004', NULL),
      (11002, 'PAY-20260326-0002', 'PTXN-0005', 'PTXN-0004',
       'REFUND', 'SUCCESS',
       'CARD', 'KCP', 'KCP-TXN-0005', 'KCP-ORD-0002',
       'KRW', 90000,
       '2026-03-26 10:59:00', '2026-03-26 11:00:00',
       NULL, NULL,
       'idem-pay-2-refund', 'PEV-2005', NULL),

      (11002, 'PAY-20260326-0003', 'PTXN-0006', NULL,
       'CANCEL', 'SUCCESS',
       'MANUAL', NULL, NULL, NULL,
       'KRW', 29000,
       '2026-03-26 09:10:00', '2026-03-26 09:11:00',
       NULL, NULL,
       'idem-pay-3-cancel', 'PEV-2006', NULL);

-- 4. Payment Allocation
INSERT INTO payment_allocation (
    payment_no, order_no, order_line_no,
    allocation_type, allocated_amount, currency_code
) VALUES
      ('PAY-20260326-0001', 'ORD-20260326-0001', 1, 'ORDER_LINE', 58000, 'KRW'),
      ('PAY-20260326-0001', 'ORD-20260326-0001', 2, 'ORDER_LINE', 1350000, 'KRW'),
      ('PAY-20260326-0002', 'ORD-20260326-0002', 1, 'ORDER_LINE', 225000, 'KRW'),
      ('PAY-20260326-0003', 'ORD-20260326-0003', 1, 'ORDER_LINE', 29000, 'KRW');

-- 5. Refund
INSERT INTO refund (
    batch_job_execution_id,
    refund_no, payment_no, order_no,
    refund_status, refund_reason_code, refund_reason_message,
    currency_code, refund_amount,
    requested_at, approved_at, processed_at, failed_at,
    failure_code, failure_message, attributes_json
) VALUES
    (
        11003,
        'RFND-20260326-0001', 'PAY-20260326-0002', 'ORD-20260326-0002',
        'PROCESSED', 'CUSTOMER_CHANGE_MIND', 'Customer requested partial cancellation',
        'KRW', 90000,
        '2026-03-26 10:50:00', '2026-03-26 10:55:00', '2026-03-26 11:00:00', NULL,
        NULL, NULL, JSON_OBJECT('partial', true)
    );

-- 6. Refund Allocation
INSERT INTO refund_allocation (
    refund_no, order_no, order_line_no,
    allocation_type, refund_amount, currency_code
) VALUES
    ('RFND-20260326-0001', 'ORD-20260326-0002', 1, 'ORDER_LINE', 90000, 'KRW');

-- 7. Payment Event
INSERT INTO payment_event (
    batch_job_execution_id,
    payment_no, payment_txn_no, order_no,
    event_type, event_status, event_id,
    event_at, actor_type, actor_id,
    message, attributes_json
) VALUES
      (11004, 'PAY-20260326-0001', 'PTXN-0001', 'ORD-20260326-0001', 'PAYMENT_AUTHORIZED', 'SUCCESS', 'PMEV-3001',
       '2026-03-26 07:31:10', 'SYSTEM', 'pg-adapter', 'Authorization success', NULL),
      (11004, 'PAY-20260326-0001', 'PTXN-0002', 'ORD-20260326-0001', 'PAYMENT_CAPTURED', 'SUCCESS', 'PMEV-3002',
       '2026-03-26 07:31:20', 'SYSTEM', 'pg-adapter', 'Capture success', NULL),
      (11004, 'PAY-20260326-0002', 'PTXN-0004', 'ORD-20260326-0002', 'PAYMENT_CAPTURED', 'SUCCESS', 'PMEV-3003',
       '2026-03-26 08:01:15', 'SYSTEM', 'pg-adapter', 'Capture success', NULL),
      (11004, 'PAY-20260326-0002', 'PTXN-0005', 'ORD-20260326-0002', 'PAYMENT_REFUNDED', 'SUCCESS', 'PMEV-3004',
       '2026-03-26 11:00:00', 'SYSTEM', 'refund-worker', 'Partial refund processed', NULL),
      (11004, 'PAY-20260326-0003', 'PTXN-0006', 'ORD-20260326-0003', 'PAYMENT_CANCELLED', 'SUCCESS', 'PMEV-3005',
       '2026-03-26 09:11:00', 'SYSTEM', 'order-cancel-worker', 'Manual payment cancelled', NULL);