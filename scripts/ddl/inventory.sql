USE inventory_db;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS v_inventory_balance;

DROP TABLE IF EXISTS inventory_snapshot;
DROP TABLE IF EXISTS inventory_transaction;
DROP TABLE IF EXISTS inventory_hold;
DROP TABLE IF EXISTS inventory_adjustment_line;
DROP TABLE IF EXISTS inventory_adjustment;
DROP TABLE IF EXISTS inventory_reservation;
DROP TABLE IF EXISTS inventory_stock;
DROP TABLE IF EXISTS inbound_receipt_line;
DROP TABLE IF EXISTS inbound_receipt;
DROP TABLE IF EXISTS item_lot;
DROP TABLE IF EXISTS item;
DROP TABLE IF EXISTS adjustment_reason;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS zone;
DROP TABLE IF EXISTS warehouse;
DROP TABLE IF EXISTS inventory_owner;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- 1. Master data
-- =========================================================

CREATE TABLE inventory_owner (
                                 owner_id                 BIGINT NOT NULL AUTO_INCREMENT,
                                 owner_code               VARCHAR(30) NOT NULL,
                                 owner_name               VARCHAR(200) NOT NULL,
                                 owner_type               ENUM('COMPANY','VENDOR','CONSIGNOR','THIRD_PARTY') NOT NULL DEFAULT 'COMPANY',
                                 is_active                TINYINT(1) NOT NULL DEFAULT 1,
                                 created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                 PRIMARY KEY (owner_id),
                                 UNIQUE KEY uq_inventory_owner_code (owner_code)
) ENGINE=InnoDB;

CREATE TABLE warehouse (
                           warehouse_id             BIGINT NOT NULL AUTO_INCREMENT,
                           warehouse_code           VARCHAR(30) NOT NULL,
                           warehouse_name           VARCHAR(200) NOT NULL,
                           country_code             VARCHAR(2) NULL,
                           timezone_name            VARCHAR(100) NULL,
                           is_active                TINYINT(1) NOT NULL DEFAULT 1,
                           created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           PRIMARY KEY (warehouse_id),
                           UNIQUE KEY uq_warehouse_code (warehouse_code)
) ENGINE=InnoDB;

CREATE TABLE zone (
                      zone_id                  BIGINT NOT NULL AUTO_INCREMENT,
                      warehouse_id             BIGINT NOT NULL,
                      zone_code                VARCHAR(30) NOT NULL,
                      zone_name                VARCHAR(200) NOT NULL,
                      zone_type                ENUM('RECEIVING','STORAGE','PICKING','PACKING','STAGING','SHIPPING','RETURN','QC','QUARANTINE','DAMAGE') NOT NULL,
                      temperature_type         ENUM('AMBIENT','CHILLED','FROZEN') NULL,
                      is_active                TINYINT(1) NOT NULL DEFAULT 1,
                      created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                      PRIMARY KEY (zone_id),
                      UNIQUE KEY uq_zone (warehouse_id, zone_code),
                      KEY ix_zone_warehouse_id (warehouse_id),
                      CONSTRAINT fk_zone_warehouse
                          FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id)
) ENGINE=InnoDB;

CREATE TABLE location (
                          location_id              BIGINT NOT NULL AUTO_INCREMENT,
                          warehouse_id             BIGINT NOT NULL,
                          zone_id                  BIGINT NULL,
                          location_code            VARCHAR(50) NOT NULL,
                          location_type            ENUM('RECEIVING','STORAGE','PICKING','PACKING','STAGING','SHIPPING','RETURN','QC','QUARANTINE','DAMAGE') NOT NULL,
                          aisle                    VARCHAR(20) NULL,
                          rack                     VARCHAR(20) NULL,
                          `level`                  VARCHAR(20) NULL,
                          bin                      VARCHAR(20) NULL,
                          capacity_unit_qty        DECIMAL(18,4) NULL,
                          capacity_volume          DECIMAL(18,4) NULL,
                          capacity_weight          DECIMAL(18,4) NULL,
                          is_pickable              TINYINT(1) NOT NULL DEFAULT 0,
                          is_active                TINYINT(1) NOT NULL DEFAULT 1,
                          created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          PRIMARY KEY (location_id),
                          UNIQUE KEY uq_location (warehouse_id, location_code),
                          KEY ix_location_warehouse_id (warehouse_id),
                          KEY ix_location_zone_id (zone_id),
                          CONSTRAINT fk_location_warehouse
                              FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
                          CONSTRAINT fk_location_zone
                              FOREIGN KEY (zone_id) REFERENCES zone(zone_id)
) ENGINE=InnoDB;

CREATE TABLE adjustment_reason (
                                   adjustment_reason_id     BIGINT NOT NULL AUTO_INCREMENT,
                                   reason_code              VARCHAR(30) NOT NULL,
                                   reason_name              VARCHAR(100) NOT NULL,
                                   reason_type              ENUM('INCREASE','DECREASE','BOTH') NOT NULL DEFAULT 'BOTH',
                                   is_active                TINYINT(1) NOT NULL DEFAULT 1,
                                   created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                   updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                   PRIMARY KEY (adjustment_reason_id),
                                   UNIQUE KEY uq_adjustment_reason_code (reason_code)
) ENGINE=InnoDB;

CREATE TABLE item (
                      item_id                  BIGINT NOT NULL AUTO_INCREMENT,
                      owner_id                 BIGINT NOT NULL,
                      item_code                VARCHAR(50) NOT NULL,
                      item_name                VARCHAR(200) NOT NULL,
                      item_description         TEXT NULL,
                      item_type                ENUM('NORMAL','SET','MATERIAL','CONSUMABLE') NOT NULL DEFAULT 'NORMAL',
                      uom                      VARCHAR(20) NOT NULL DEFAULT 'EA',
                      unit_weight              DECIMAL(18,4) NULL,
                      unit_volume              DECIMAL(18,6) NULL,
                      shelf_life_days          INT NULL,
                      lot_controlled           TINYINT(1) NOT NULL DEFAULT 0,
                      serial_controlled        TINYINT(1) NOT NULL DEFAULT 0,
                      inbound_inspection_required TINYINT(1) NOT NULL DEFAULT 0,
                      abc_class                VARCHAR(1) NULL,
                      is_active                TINYINT(1) NOT NULL DEFAULT 1,
                      created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                      PRIMARY KEY (item_id),
                      UNIQUE KEY uq_item_code (item_code),
                      KEY ix_item_owner_id (owner_id),
                      CONSTRAINT fk_item_owner
                          FOREIGN KEY (owner_id) REFERENCES inventory_owner(owner_id)
) ENGINE=InnoDB;

CREATE TABLE item_lot (
                          lot_id                   BIGINT NOT NULL AUTO_INCREMENT,
                          item_id                  BIGINT NOT NULL,
                          lot_no                   VARCHAR(100) NOT NULL,
                          manufacture_date         DATE NULL,
                          expiry_date              DATE NULL,
                          vendor_lot_no            VARCHAR(100) NULL,
                          receipt_status           ENUM('NORMAL','HOLD','EXPIRED','QUARANTINED') NOT NULL DEFAULT 'NORMAL',
                          attributes_json          JSON NULL,
                          created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          PRIMARY KEY (lot_id),
                          UNIQUE KEY uq_item_lot (item_id, lot_no),
                          KEY ix_item_lot_item_id (item_id),
                          KEY ix_item_lot_expiry_date (expiry_date),
                          CONSTRAINT fk_item_lot_item
                              FOREIGN KEY (item_id) REFERENCES item(item_id),
                          CONSTRAINT ck_item_lot_dates CHECK (
                              expiry_date IS NULL OR manufacture_date IS NULL OR expiry_date >= manufacture_date
                              )
) ENGINE=InnoDB;

-- =========================================================
-- 2. Inbound receiving
-- =========================================================

CREATE TABLE inbound_receipt (
                                 inbound_receipt_id       BIGINT NOT NULL AUTO_INCREMENT,
                                 warehouse_id             BIGINT NOT NULL,
                                 owner_id                 BIGINT NOT NULL,
                                 receipt_no               VARCHAR(50) NOT NULL,
                                 source_type              ENUM('PURCHASE_ORDER','TRANSFER_IN','RETURN','MANUAL') NOT NULL,
                                 source_no                VARCHAR(100) NULL,
                                 receipt_status           ENUM('REQUESTED','RECEIVING','COMPLETED','CANCELLED') NOT NULL DEFAULT 'REQUESTED',
                                 received_at              DATETIME NULL,
                                 created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                 PRIMARY KEY (inbound_receipt_id),
                                 UNIQUE KEY uq_inbound_receipt_no (receipt_no),
                                 KEY ix_inbound_receipt_warehouse_id (warehouse_id),
                                 KEY ix_inbound_receipt_owner_id (owner_id),
                                 KEY ix_inbound_receipt_source (source_type, source_no),
                                 CONSTRAINT fk_inbound_receipt_warehouse
                                     FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
                                 CONSTRAINT fk_inbound_receipt_owner
                                     FOREIGN KEY (owner_id) REFERENCES inventory_owner(owner_id)
) ENGINE=InnoDB;

CREATE TABLE inbound_receipt_line (
                                      inbound_receipt_line_id  BIGINT NOT NULL AUTO_INCREMENT,
                                      inbound_receipt_id       BIGINT NOT NULL,
                                      line_no                  INT NOT NULL,
                                      item_id                  BIGINT NOT NULL,
                                      lot_id                   BIGINT NULL,
                                      expected_qty             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                      received_qty             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                      accepted_qty             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                      rejected_qty             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                      putaway_location_id      BIGINT NULL,
                                      line_status              ENUM('OPEN','PARTIAL','COMPLETED','CANCELLED') NOT NULL DEFAULT 'OPEN',
                                      remark                   VARCHAR(500) NULL,
                                      created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                      PRIMARY KEY (inbound_receipt_line_id),
                                      UNIQUE KEY uq_inbound_receipt_line (inbound_receipt_id, line_no),
                                      KEY ix_inbound_receipt_line_item_id (item_id),
                                      KEY ix_inbound_receipt_line_lot_id (lot_id),
                                      KEY ix_inbound_receipt_line_putaway_location_id (putaway_location_id),
                                      CONSTRAINT fk_inbound_receipt_line_receipt
                                          FOREIGN KEY (inbound_receipt_id) REFERENCES inbound_receipt(inbound_receipt_id),
                                      CONSTRAINT fk_inbound_receipt_line_item
                                          FOREIGN KEY (item_id) REFERENCES item(item_id),
                                      CONSTRAINT fk_inbound_receipt_line_lot
                                          FOREIGN KEY (lot_id) REFERENCES item_lot(lot_id),
                                      CONSTRAINT fk_inbound_receipt_line_putaway_location
                                          FOREIGN KEY (putaway_location_id) REFERENCES location(location_id),
                                      CONSTRAINT ck_inbound_receipt_line_qty CHECK (
                                          expected_qty >= 0 AND received_qty >= 0 AND accepted_qty >= 0 AND rejected_qty >= 0
                                              AND accepted_qty + rejected_qty <= received_qty
                                          )
) ENGINE=InnoDB;

-- =========================================================
-- 3. Current stock
-- =========================================================

CREATE TABLE inventory_stock (
                                 inventory_stock_id       BIGINT NOT NULL AUTO_INCREMENT,
                                 owner_id                 BIGINT NOT NULL,
                                 warehouse_id             BIGINT NOT NULL,
                                 location_id              BIGINT NOT NULL,
                                 item_id                  BIGINT NOT NULL,
                                 lot_id                   BIGINT NULL,
                                 stock_status             ENUM('AVAILABLE','ALLOCATED','PICKED','IN_TRANSIT','QUARANTINE','DAMAGED','HOLD') NOT NULL DEFAULT 'AVAILABLE',
                                 on_hand_qty              DECIMAL(18,4) NOT NULL DEFAULT 0,
                                 allocated_qty            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                 picked_qty               DECIMAL(18,4) NOT NULL DEFAULT 0,
                                 available_qty            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                 last_transaction_at      DATETIME NULL,
                                 created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                 lot_id_normalized        BIGINT GENERATED ALWAYS AS (IFNULL(lot_id, -1)) STORED,
                                 PRIMARY KEY (inventory_stock_id),
                                 UNIQUE KEY uq_inventory_stock (owner_id, warehouse_id, location_id, item_id, lot_id_normalized, stock_status),
                                 KEY ix_inventory_stock_item (item_id),
                                 KEY ix_inventory_stock_location (location_id),
                                 KEY ix_inventory_stock_owner_warehouse (owner_id, warehouse_id),
                                 CONSTRAINT fk_inventory_stock_owner
                                     FOREIGN KEY (owner_id) REFERENCES inventory_owner(owner_id),
                                 CONSTRAINT fk_inventory_stock_warehouse
                                     FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
                                 CONSTRAINT fk_inventory_stock_location
                                     FOREIGN KEY (location_id) REFERENCES location(location_id),
                                 CONSTRAINT fk_inventory_stock_item
                                     FOREIGN KEY (item_id) REFERENCES item(item_id),
                                 CONSTRAINT fk_inventory_stock_lot
                                     FOREIGN KEY (lot_id) REFERENCES item_lot(lot_id),
                                 CONSTRAINT ck_inventory_stock_qty_nonnegative CHECK (
                                     on_hand_qty >= 0 AND allocated_qty >= 0 AND picked_qty >= 0 AND available_qty >= 0
                                     )
) ENGINE=InnoDB;

-- =========================================================
-- 4. Reservation / hold / adjustment
-- =========================================================

CREATE TABLE inventory_reservation (
                                       reservation_id           BIGINT NOT NULL AUTO_INCREMENT,
                                       owner_id                 BIGINT NOT NULL,
                                       warehouse_id             BIGINT NOT NULL,
                                       location_id              BIGINT NULL,
                                       item_id                  BIGINT NOT NULL,
                                       lot_id                   BIGINT NULL,
                                       reference_type           ENUM('OUTBOUND_ORDER','TRANSFER_ORDER','RETURN_ORDER','MANUAL') NOT NULL,
                                       reference_no             VARCHAR(100) NOT NULL,
                                       reference_line_no        VARCHAR(50) NULL,
                                       reserved_qty             DECIMAL(18,4) NOT NULL,
                                       released_qty             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       reservation_status       ENUM('ACTIVE','PARTIALLY_RELEASED','RELEASED','CANCELLED','EXPIRED') NOT NULL DEFAULT 'ACTIVE',
                                       reserved_at              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       expires_at               DATETIME NULL,
                                       created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                       PRIMARY KEY (reservation_id),
                                       KEY ix_inventory_reservation_ref (reference_type, reference_no, reference_line_no),
                                       KEY ix_inventory_reservation_item (item_id),
                                       KEY ix_inventory_reservation_status (reservation_status),
                                       CONSTRAINT fk_inventory_reservation_owner
                                           FOREIGN KEY (owner_id) REFERENCES inventory_owner(owner_id),
                                       CONSTRAINT fk_inventory_reservation_warehouse
                                           FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
                                       CONSTRAINT fk_inventory_reservation_location
                                           FOREIGN KEY (location_id) REFERENCES location(location_id),
                                       CONSTRAINT fk_inventory_reservation_item
                                           FOREIGN KEY (item_id) REFERENCES item(item_id),
                                       CONSTRAINT fk_inventory_reservation_lot
                                           FOREIGN KEY (lot_id) REFERENCES item_lot(lot_id),
                                       CONSTRAINT ck_inventory_reservation_qty CHECK (
                                           reserved_qty >= 0 AND released_qty >= 0 AND released_qty <= reserved_qty
                                           )
) ENGINE=InnoDB;

CREATE TABLE inventory_adjustment (
                                      inventory_adjustment_id  BIGINT NOT NULL AUTO_INCREMENT,
                                      warehouse_id             BIGINT NOT NULL,
                                      adjustment_no            VARCHAR(50) NOT NULL,
                                      adjustment_type          ENUM('INCREASE','DECREASE','RECOUNT') NOT NULL,
                                      adjustment_status        ENUM('REQUESTED','APPROVED','POSTED','CANCELLED') NOT NULL DEFAULT 'REQUESTED',
                                      requested_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      approved_at              DATETIME NULL,
                                      posted_at                DATETIME NULL,
                                      requested_by             VARCHAR(100) NOT NULL,
                                      approved_by              VARCHAR(100) NULL,
                                      remark                   VARCHAR(500) NULL,
                                      created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                      PRIMARY KEY (inventory_adjustment_id),
                                      UNIQUE KEY uq_inventory_adjustment_no (adjustment_no),
                                      KEY ix_inventory_adjustment_warehouse_id (warehouse_id),
                                      KEY ix_inventory_adjustment_status (adjustment_status),
                                      CONSTRAINT fk_inventory_adjustment_warehouse
                                          FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id)
) ENGINE=InnoDB;

CREATE TABLE inventory_adjustment_line (
                                           inventory_adjustment_line_id BIGINT NOT NULL AUTO_INCREMENT,
                                           inventory_adjustment_id   BIGINT NOT NULL,
                                           line_no                   INT NOT NULL,
                                           owner_id                  BIGINT NOT NULL,
                                           location_id               BIGINT NOT NULL,
                                           item_id                   BIGINT NOT NULL,
                                           lot_id                    BIGINT NULL,
                                           adjustment_reason_id      BIGINT NOT NULL,
                                           system_qty                DECIMAL(18,4) NOT NULL DEFAULT 0,
                                           counted_qty               DECIMAL(18,4) NULL,
                                           adjusted_qty              DECIMAL(18,4) NOT NULL,
                                           created_at                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                           updated_at                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                           PRIMARY KEY (inventory_adjustment_line_id),
                                           UNIQUE KEY uq_inventory_adjustment_line (inventory_adjustment_id, line_no),
                                           KEY ix_inventory_adjustment_line_item_id (item_id),
                                           CONSTRAINT fk_inventory_adjustment_line_adjustment
                                               FOREIGN KEY (inventory_adjustment_id) REFERENCES inventory_adjustment(inventory_adjustment_id),
                                           CONSTRAINT fk_inventory_adjustment_line_owner
                                               FOREIGN KEY (owner_id) REFERENCES inventory_owner(owner_id),
                                           CONSTRAINT fk_inventory_adjustment_line_location
                                               FOREIGN KEY (location_id) REFERENCES location(location_id),
                                           CONSTRAINT fk_inventory_adjustment_line_item
                                               FOREIGN KEY (item_id) REFERENCES item(item_id),
                                           CONSTRAINT fk_inventory_adjustment_line_lot
                                               FOREIGN KEY (lot_id) REFERENCES item_lot(lot_id),
                                           CONSTRAINT fk_inventory_adjustment_line_reason
                                               FOREIGN KEY (adjustment_reason_id) REFERENCES adjustment_reason(adjustment_reason_id)
) ENGINE=InnoDB;

CREATE TABLE inventory_hold (
                                inventory_hold_id        BIGINT NOT NULL AUTO_INCREMENT,
                                owner_id                 BIGINT NOT NULL,
                                warehouse_id             BIGINT NOT NULL,
                                location_id              BIGINT NULL,
                                item_id                  BIGINT NOT NULL,
                                lot_id                   BIGINT NULL,
                                hold_type                ENUM('QUALITY','EXPIRY','DAMAGE','CUSTOMER_REQUEST','MANUAL') NOT NULL,
                                hold_reason              VARCHAR(255) NOT NULL,
                                hold_status              ENUM('ACTIVE','RELEASED') NOT NULL DEFAULT 'ACTIVE',
                                held_qty                 DECIMAL(18,4) NOT NULL,
                                released_qty             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                held_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                released_at              DATETIME NULL,
                                created_by               VARCHAR(100) NOT NULL,
                                released_by              VARCHAR(100) NULL,
                                created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                PRIMARY KEY (inventory_hold_id),
                                KEY ix_inventory_hold_item (item_id),
                                KEY ix_inventory_hold_status (hold_status),
                                CONSTRAINT fk_inventory_hold_owner
                                    FOREIGN KEY (owner_id) REFERENCES inventory_owner(owner_id),
                                CONSTRAINT fk_inventory_hold_warehouse
                                    FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
                                CONSTRAINT fk_inventory_hold_location
                                    FOREIGN KEY (location_id) REFERENCES location(location_id),
                                CONSTRAINT fk_inventory_hold_item
                                    FOREIGN KEY (item_id) REFERENCES item(item_id),
                                CONSTRAINT fk_inventory_hold_lot
                                    FOREIGN KEY (lot_id) REFERENCES item_lot(lot_id),
                                CONSTRAINT ck_inventory_hold_qty CHECK (
                                    held_qty >= 0 AND released_qty >= 0 AND released_qty <= held_qty
                                    )
) ENGINE=InnoDB;

-- =========================================================
-- 5. Ledger / snapshot
-- =========================================================

CREATE TABLE inventory_transaction (
                                       inventory_transaction_id BIGINT NOT NULL AUTO_INCREMENT,
                                       transaction_type         ENUM('RECEIPT','PUTAWAY','MOVE','ALLOCATE','DEALLOCATE','PICK','SHIP','ADJUSTMENT_INCREASE','ADJUSTMENT_DECREASE','RETURN_RECEIPT','SCRAP','TRANSFER_IN','TRANSFER_OUT','HOLD','RELEASE_HOLD') NOT NULL,
                                       reference_type           ENUM('INBOUND_RECEIPT','OUTBOUND_ORDER','TRANSFER_ORDER','RETURN_ORDER','ADJUSTMENT','HOLD','MANUAL') NOT NULL DEFAULT 'MANUAL',
                                       reference_no             VARCHAR(100) NULL,
                                       reference_line_no        VARCHAR(50) NULL,
                                       warehouse_id             BIGINT NOT NULL,
                                       owner_id                 BIGINT NOT NULL,
                                       from_location_id         BIGINT NULL,
                                       to_location_id           BIGINT NULL,
                                       item_id                  BIGINT NOT NULL,
                                       lot_id                   BIGINT NULL,
                                       stock_status_before      ENUM('AVAILABLE','ALLOCATED','PICKED','IN_TRANSIT','QUARANTINE','DAMAGED','HOLD') NULL,
                                       stock_status_after       ENUM('AVAILABLE','ALLOCATED','PICKED','IN_TRANSIT','QUARANTINE','DAMAGED','HOLD') NULL,
                                       quantity                 DECIMAL(18,4) NOT NULL,
                                       uom                      VARCHAR(20) NOT NULL DEFAULT 'EA',
                                       on_hand_before           DECIMAL(18,4) NULL,
                                       on_hand_after            DECIMAL(18,4) NULL,
                                       allocated_before         DECIMAL(18,4) NULL,
                                       allocated_after          DECIMAL(18,4) NULL,
                                       available_before         DECIMAL(18,4) NULL,
                                       available_after          DECIMAL(18,4) NULL,
                                       transaction_at           DATETIME NOT NULL,
                                       created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       created_by               VARCHAR(100) NOT NULL DEFAULT 'system',
                                       remark                   TEXT NULL,
                                       attributes_json          JSON NULL,
                                       PRIMARY KEY (inventory_transaction_id),
                                       KEY ix_inventory_transaction_time (transaction_at),
                                       KEY ix_inventory_transaction_item_time (item_id, transaction_at),
                                       KEY ix_inventory_transaction_ref (reference_type, reference_no, reference_line_no),
                                       KEY ix_inventory_transaction_from_loc (from_location_id),
                                       KEY ix_inventory_transaction_to_loc (to_location_id),
                                       CONSTRAINT fk_inventory_transaction_warehouse
                                           FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
                                       CONSTRAINT fk_inventory_transaction_owner
                                           FOREIGN KEY (owner_id) REFERENCES inventory_owner(owner_id),
                                       CONSTRAINT fk_inventory_transaction_from_location
                                           FOREIGN KEY (from_location_id) REFERENCES location(location_id),
                                       CONSTRAINT fk_inventory_transaction_to_location
                                           FOREIGN KEY (to_location_id) REFERENCES location(location_id),
                                       CONSTRAINT fk_inventory_transaction_item
                                           FOREIGN KEY (item_id) REFERENCES item(item_id),
                                       CONSTRAINT fk_inventory_transaction_lot
                                           FOREIGN KEY (lot_id) REFERENCES item_lot(lot_id),
                                       CONSTRAINT ck_inventory_transaction_qty_positive CHECK (quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE inventory_snapshot (
                                    inventory_snapshot_id    BIGINT NOT NULL AUTO_INCREMENT,
                                    snapshot_at              DATETIME NOT NULL,
                                    owner_id                 BIGINT NOT NULL,
                                    warehouse_id             BIGINT NOT NULL,
                                    location_id              BIGINT NOT NULL,
                                    item_id                  BIGINT NOT NULL,
                                    lot_id                   BIGINT NULL,
                                    stock_status             ENUM('AVAILABLE','ALLOCATED','PICKED','IN_TRANSIT','QUARANTINE','DAMAGED','HOLD') NOT NULL,
                                    on_hand_qty              DECIMAL(18,4) NOT NULL DEFAULT 0,
                                    allocated_qty            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                    picked_qty               DECIMAL(18,4) NOT NULL DEFAULT 0,
                                    available_qty            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                    created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                    PRIMARY KEY (inventory_snapshot_id),
                                    KEY ix_inventory_snapshot_time (snapshot_at),
                                    KEY ix_inventory_snapshot_item (item_id, snapshot_at),
                                    KEY ix_inventory_snapshot_location (warehouse_id, location_id, snapshot_at),
                                    CONSTRAINT fk_inventory_snapshot_owner
                                        FOREIGN KEY (owner_id) REFERENCES inventory_owner(owner_id),
                                    CONSTRAINT fk_inventory_snapshot_warehouse
                                        FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
                                    CONSTRAINT fk_inventory_snapshot_location
                                        FOREIGN KEY (location_id) REFERENCES location(location_id),
                                    CONSTRAINT fk_inventory_snapshot_item
                                        FOREIGN KEY (item_id) REFERENCES item(item_id),
                                    CONSTRAINT fk_inventory_snapshot_lot
                                        FOREIGN KEY (lot_id) REFERENCES item_lot(lot_id),
                                    CONSTRAINT ck_inventory_snapshot_qty_nonnegative CHECK (
                                        on_hand_qty >= 0 AND allocated_qty >= 0 AND picked_qty >= 0 AND available_qty >= 0
                                        )
) ENGINE=InnoDB;

-- =========================================================
-- 6. View
-- =========================================================

CREATE OR REPLACE VIEW v_inventory_balance AS
SELECT
    s.owner_id,
    o.owner_code,
    o.owner_name,
    s.warehouse_id,
    w.warehouse_code,
    s.location_id,
    l.location_code,
    s.item_id,
    i.item_code,
    i.item_name,
    s.lot_id,
    il.lot_no,
    s.stock_status,
    s.on_hand_qty,
    s.allocated_qty,
    s.picked_qty,
    s.available_qty,
    s.last_transaction_at
FROM inventory_stock s
         JOIN inventory_owner o
              ON o.owner_id = s.owner_id
         JOIN warehouse w
              ON w.warehouse_id = s.warehouse_id
         JOIN location l
              ON l.location_id = s.location_id
         JOIN item i
              ON i.item_id = s.item_id
         LEFT JOIN item_lot il
                   ON il.lot_id = s.lot_id;

-- =========================================================
-- 7. Seed data
-- =========================================================

INSERT INTO adjustment_reason (reason_code, reason_name, reason_type)
VALUES
    ('FOUND', 'Found Stock', 'INCREASE'),
    ('LOSS', 'Loss', 'DECREASE'),
    ('DAMAGE', 'Damage', 'DECREASE'),
    ('EXPIRED', 'Expired', 'DECREASE'),
    ('COUNT_DIFF', 'Cycle Count Difference', 'BOTH')
ON DUPLICATE KEY UPDATE
                     reason_name = VALUES(reason_name),
                     reason_type = VALUES(reason_type),
                     updated_at = CURRENT_TIMESTAMP;
