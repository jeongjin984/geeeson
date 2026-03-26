USE order_db;

-- =========================================================
-- ORDER DOMAIN FINAL DDL
-- - 도메인 내부 정합성 강화
-- - batch/simulation 같은 기술성 필드 제거
-- - 주문 금액 / 취소 / 반품 / 출하 / 패키지 구조 보강
-- - product / inventory / payment 와 직접 FK 연결하지 않음
-- =========================================================

-- =========================================================
-- 1. Outbound Order Header
-- =========================================================
CREATE TABLE IF NOT EXISTS outbound_order (
                                              outbound_order_id          BIGINT NOT NULL AUTO_INCREMENT,

                                              order_no                   VARCHAR(50) NOT NULL,
                                              external_order_no          VARCHAR(100) NULL,
                                              sales_channel_code         VARCHAR(50) NULL,
                                              order_type                 ENUM(
                                                  'NORMAL',
                                                  'EXPRESS',
                                                  'TRANSFER',
                                                  'RETURN_REPLACEMENT'
                                                  ) NOT NULL DEFAULT 'NORMAL',
                                              order_status               ENUM(
                                                  'CREATED',
                                                  'CONFIRMED',
                                                  'RELEASED',
                                                  'ALLOCATING',
                                                  'ALLOCATED',
                                                  'PARTIALLY_ALLOCATED',
                                                  'PICKING',
                                                  'PICKED',
                                                  'PACKING',
                                                  'PACKED',
                                                  'PARTIALLY_SHIPPED',
                                                  'SHIPPED',
                                                  'DELIVERED',
                                                  'PARTIALLY_CANCELLED',
                                                  'CANCELLED',
                                                  'CLOSED'
                                                  ) NOT NULL DEFAULT 'CREATED',
                                              payment_status             ENUM(
                                                  'PENDING',
                                                  'AUTHORIZED',
                                                  'PARTIALLY_PAID',
                                                  'PAID',
                                                  'PARTIALLY_REFUNDED',
                                                  'REFUNDED',
                                                  'FAILED'
                                                  ) NOT NULL DEFAULT 'PENDING',

                                              fulfillment_center_code    VARCHAR(30) NOT NULL,
                                              currency_code              CHAR(3) NOT NULL DEFAULT 'KRW',

                                              customer_code              VARCHAR(50) NULL,
                                              customer_name              VARCHAR(200) NULL,
                                              customer_email             VARCHAR(255) NULL,
                                              customer_phone             VARCHAR(50) NULL,

                                              orderer_name               VARCHAR(200) NULL,
                                              orderer_phone              VARCHAR(50) NULL,
                                              orderer_email              VARCHAR(255) NULL,

                                              recipient_name             VARCHAR(200) NULL,
                                              recipient_phone            VARCHAR(50) NULL,
                                              recipient_zip_code         VARCHAR(20) NULL,
                                              recipient_address1         VARCHAR(255) NULL,
                                              recipient_address2         VARCHAR(255) NULL,
                                              recipient_city             VARCHAR(100) NULL,
                                              recipient_state            VARCHAR(100) NULL,
                                              recipient_country_code     VARCHAR(2) NULL,

                                              billing_name               VARCHAR(200) NULL,
                                              billing_phone              VARCHAR(50) NULL,
                                              billing_email              VARCHAR(255) NULL,

                                              delivery_instruction       VARCHAR(500) NULL,
                                              carrier_code               VARCHAR(50) NULL,
                                              service_level              VARCHAR(50) NULL,
                                              priority                   INT NOT NULL DEFAULT 5,

                                              requested_ship_at          DATETIME NULL,
                                              promised_delivery_at       DATETIME NULL,
                                              ordered_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              confirmed_at               DATETIME NULL,
                                              released_at                DATETIME NULL,
                                              allocated_at               DATETIME NULL,
                                              first_shipped_at           DATETIME NULL,
                                              shipped_at                 DATETIME NULL,
                                              delivered_at               DATETIME NULL,
                                              cancelled_at               DATETIME NULL,
                                              closed_at                  DATETIME NULL,

                                              total_order_qty            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              total_allocated_qty        DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              total_shipped_qty          DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              total_cancelled_qty        DECIMAL(18,4) NOT NULL DEFAULT 0,

                                              item_amount                DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              item_discount_amount       DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              order_discount_amount      DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              shipping_amount            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              shipping_discount_amount   DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              tax_amount                 DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              paid_amount                DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              cancelled_amount           DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              refunded_amount            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              net_order_amount           DECIMAL(18,4) NOT NULL DEFAULT 0,

                                              attributes_json            JSON NULL,
                                              created_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              updated_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                              PRIMARY KEY (outbound_order_id),
                                              UNIQUE KEY uq_outbound_order_order_no (order_no),
                                              KEY ix_outbound_order_external_order_no (external_order_no),
                                              KEY ix_outbound_order_status (order_status),
                                              KEY ix_outbound_order_payment_status (payment_status),
                                              KEY ix_outbound_order_fc_status (fulfillment_center_code, order_status),
                                              KEY ix_outbound_order_ordered_at (ordered_at),
                                              KEY ix_outbound_order_requested_ship_at (requested_ship_at),
                                              KEY ix_outbound_order_customer_code (customer_code),
                                              KEY ix_outbound_order_channel (sales_channel_code),

                                              CONSTRAINT ck_outbound_order_priority CHECK (priority >= 0),
                                              CONSTRAINT ck_outbound_order_qty CHECK (
                                                  total_order_qty >= 0
                                                      AND total_allocated_qty >= 0
                                                      AND total_shipped_qty >= 0
                                                      AND total_cancelled_qty >= 0
                                                      AND total_allocated_qty <= total_order_qty
                                                      AND total_shipped_qty <= total_order_qty
                                                      AND total_cancelled_qty <= total_order_qty
                                                  ),
                                              CONSTRAINT ck_outbound_order_amount CHECK (
                                                  item_amount >= 0
                                                      AND item_discount_amount >= 0
                                                      AND order_discount_amount >= 0
                                                      AND shipping_amount >= 0
                                                      AND shipping_discount_amount >= 0
                                                      AND tax_amount >= 0
                                                      AND paid_amount >= 0
                                                      AND cancelled_amount >= 0
                                                      AND refunded_amount >= 0
                                                      AND net_order_amount >= 0
                                                  )
) ENGINE=InnoDB;

-- =========================================================
-- 2. Outbound Order Line
-- =========================================================
CREATE TABLE IF NOT EXISTS outbound_order_line (
                                                   outbound_order_line_id      BIGINT NOT NULL AUTO_INCREMENT,
                                                   outbound_order_id           BIGINT NOT NULL,

                                                   line_no                     INT NOT NULL,
                                                   line_status                 ENUM(
                                                       'CREATED',
                                                       'CONFIRMED',
                                                       'ALLOCATING',
                                                       'ALLOCATED',
                                                       'PARTIALLY_ALLOCATED',
                                                       'PICKING',
                                                       'PICKED',
                                                       'PACKING',
                                                       'PACKED',
                                                       'PARTIALLY_SHIPPED',
                                                       'SHIPPED',
                                                       'PARTIALLY_CANCELLED',
                                                       'CANCELLED',
                                                       'RETURN_REQUESTED',
                                                       'RETURNED',
                                                       'CLOSED'
                                                       ) NOT NULL DEFAULT 'CREATED',

                                                   sku_code                    VARCHAR(50) NOT NULL,
                                                   sku_name                    VARCHAR(200) NULL,
                                                   product_code                VARCHAR(50) NULL,
                                                   product_name                VARCHAR(200) NULL,

                                                   ordered_qty                 DECIMAL(18,4) NOT NULL,
                                                   allocated_qty               DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   picked_qty                  DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   packed_qty                  DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   shipped_qty                 DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   cancelled_qty               DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   returned_qty                DECIMAL(18,4) NOT NULL DEFAULT 0,

                                                   uom                         VARCHAR(20) NOT NULL DEFAULT 'EA',
                                                   requested_lot_no            VARCHAR(100) NULL,
                                                   lot_strict_yn               TINYINT(1) NOT NULL DEFAULT 0,

                                                   unit_price                  DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   sale_price                  DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   line_discount_amount        DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   coupon_discount_amount      DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   tax_amount                  DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   net_line_amount             DECIMAL(18,4) NOT NULL DEFAULT 0,

                                                   requested_ship_at           DATETIME NULL,
                                                   allocated_at                DATETIME NULL,
                                                   picked_at                   DATETIME NULL,
                                                   packed_at                   DATETIME NULL,
                                                   shipped_at                  DATETIME NULL,
                                                   cancelled_at                DATETIME NULL,
                                                   returned_at                 DATETIME NULL,

                                                   attributes_json             JSON NULL,
                                                   created_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                   updated_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                   PRIMARY KEY (outbound_order_line_id),
                                                   UNIQUE KEY uq_outbound_order_line (outbound_order_id, line_no),
                                                   KEY ix_outbound_order_line_sku_code (sku_code),
                                                   KEY ix_outbound_order_line_status (line_status),
                                                   KEY ix_outbound_order_line_order_status (outbound_order_id, line_status),
                                                   KEY ix_outbound_order_line_product_code (product_code),

                                                   CONSTRAINT fk_outbound_order_line_order
                                                       FOREIGN KEY (outbound_order_id) REFERENCES outbound_order(outbound_order_id),

                                                   CONSTRAINT ck_outbound_order_line_qty CHECK (
                                                       ordered_qty > 0
                                                           AND allocated_qty >= 0
                                                           AND picked_qty >= 0
                                                           AND packed_qty >= 0
                                                           AND shipped_qty >= 0
                                                           AND cancelled_qty >= 0
                                                           AND returned_qty >= 0
                                                           AND allocated_qty <= ordered_qty
                                                           AND picked_qty <= ordered_qty
                                                           AND packed_qty <= ordered_qty
                                                           AND shipped_qty <= ordered_qty
                                                           AND cancelled_qty <= ordered_qty
                                                           AND returned_qty <= shipped_qty
                                                           AND shipped_qty + cancelled_qty <= ordered_qty
                                                       ),
                                                   CONSTRAINT ck_outbound_order_line_amount CHECK (
                                                       unit_price >= 0
                                                           AND sale_price >= 0
                                                           AND line_discount_amount >= 0
                                                           AND coupon_discount_amount >= 0
                                                           AND tax_amount >= 0
                                                           AND net_line_amount >= 0
                                                       )
) ENGINE=InnoDB;

-- =========================================================
-- 3. Order Fulfillment Result
-- 주문 기준 fulfillment 상태를 별도 관리
-- =========================================================
CREATE TABLE IF NOT EXISTS outbound_order_fulfillment (
                                                          outbound_order_fulfillment_id BIGINT NOT NULL AUTO_INCREMENT,
                                                          outbound_order_line_id        BIGINT NOT NULL,

                                                          fulfillment_status            ENUM(
                                                              'REQUESTED',
                                                              'ALLOCATING',
                                                              'ALLOCATED',
                                                              'PARTIALLY_ALLOCATED',
                                                              'RELEASED',
                                                              'PICKED',
                                                              'PACKED',
                                                              'SHIPPED',
                                                              'CANCELLED'
                                                              ) NOT NULL DEFAULT 'REQUESTED',

                                                          fulfillment_ref_no            VARCHAR(100) NULL,
                                                          reservation_ref_no            VARCHAR(100) NULL,
                                                          wave_no                       VARCHAR(50) NULL,
                                                          picking_task_no               VARCHAR(50) NULL,

                                                          allocated_qty                 DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                          picked_qty                    DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                          packed_qty                    DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                          shipped_qty                   DECIMAL(18,4) NOT NULL DEFAULT 0,

                                                          allocated_at                  DATETIME NULL,
                                                          picked_at                     DATETIME NULL,
                                                          packed_at                     DATETIME NULL,
                                                          shipped_at                    DATETIME NULL,

                                                          message                       VARCHAR(500) NULL,
                                                          attributes_json               JSON NULL,
                                                          created_at                    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                          updated_at                    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                          PRIMARY KEY (outbound_order_fulfillment_id),
                                                          UNIQUE KEY uq_outbound_order_fulfillment_line (outbound_order_line_id),
                                                          KEY ix_outbound_order_fulfillment_status (fulfillment_status),
                                                          KEY ix_outbound_order_fulfillment_ref (fulfillment_ref_no),
                                                          KEY ix_outbound_order_fulfillment_reservation_ref (reservation_ref_no),
                                                          KEY ix_outbound_order_fulfillment_wave_no (wave_no),

                                                          CONSTRAINT fk_outbound_order_fulfillment_line
                                                              FOREIGN KEY (outbound_order_line_id) REFERENCES outbound_order_line(outbound_order_line_id),

                                                          CONSTRAINT ck_outbound_order_fulfillment_qty CHECK (
                                                              allocated_qty >= 0
                                                                  AND picked_qty >= 0
                                                                  AND packed_qty >= 0
                                                                  AND shipped_qty >= 0
                                                              )
) ENGINE=InnoDB;

-- =========================================================
-- 4. Order Cancel Header
-- =========================================================
CREATE TABLE IF NOT EXISTS order_cancel (
                                            order_cancel_id              BIGINT NOT NULL AUTO_INCREMENT,
                                            outbound_order_id            BIGINT NOT NULL,

                                            cancel_no                    VARCHAR(50) NOT NULL,
                                            cancel_status                ENUM(
                                                'REQUESTED',
                                                'APPROVED',
                                                'REJECTED',
                                                'COMPLETED'
                                                ) NOT NULL DEFAULT 'REQUESTED',
                                            cancel_reason_code           VARCHAR(50) NULL,
                                            cancel_reason_detail         VARCHAR(500) NULL,
                                            requested_by_type            VARCHAR(50) NOT NULL DEFAULT 'CUSTOMER',
                                            requested_by_id              VARCHAR(100) NULL,
                                            requested_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                            approved_at                  DATETIME NULL,
                                            rejected_at                  DATETIME NULL,
                                            completed_at                 DATETIME NULL,

                                            total_cancel_qty             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                            total_cancel_amount          DECIMAL(18,4) NOT NULL DEFAULT 0,

                                            attributes_json              JSON NULL,
                                            created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                            updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                            PRIMARY KEY (order_cancel_id),
                                            UNIQUE KEY uq_order_cancel_no (cancel_no),
                                            KEY ix_order_cancel_order_id (outbound_order_id),
                                            KEY ix_order_cancel_status (cancel_status),
                                            KEY ix_order_cancel_requested_at (requested_at),

                                            CONSTRAINT fk_order_cancel_order
                                                FOREIGN KEY (outbound_order_id) REFERENCES outbound_order(outbound_order_id),

                                            CONSTRAINT ck_order_cancel_amount CHECK (
                                                total_cancel_qty >= 0
                                                    AND total_cancel_amount >= 0
                                                )
) ENGINE=InnoDB;

-- =========================================================
-- 5. Order Cancel Line
-- =========================================================
CREATE TABLE IF NOT EXISTS order_cancel_line (
                                                 order_cancel_line_id         BIGINT NOT NULL AUTO_INCREMENT,
                                                 order_cancel_id              BIGINT NOT NULL,
                                                 outbound_order_line_id       BIGINT NOT NULL,

                                                 cancel_qty                   DECIMAL(18,4) NOT NULL,
                                                 cancel_amount                DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                 cancel_reason_code           VARCHAR(50) NULL,
                                                 cancel_reason_detail         VARCHAR(500) NULL,

                                                 attributes_json              JSON NULL,
                                                 created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                 updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                 PRIMARY KEY (order_cancel_line_id),
                                                 UNIQUE KEY uq_order_cancel_line (order_cancel_id, outbound_order_line_id),
                                                 KEY ix_order_cancel_line_order_line_id (outbound_order_line_id),

                                                 CONSTRAINT fk_order_cancel_line_cancel
                                                     FOREIGN KEY (order_cancel_id) REFERENCES order_cancel(order_cancel_id),
                                                 CONSTRAINT fk_order_cancel_line_order_line
                                                     FOREIGN KEY (outbound_order_line_id) REFERENCES outbound_order_line(outbound_order_line_id),

                                                 CONSTRAINT ck_order_cancel_line_qty CHECK (
                                                     cancel_qty > 0
                                                         AND cancel_amount >= 0
                                                     )
) ENGINE=InnoDB;

-- =========================================================
-- 6. Return Request Header
-- =========================================================
CREATE TABLE IF NOT EXISTS return_request (
                                              return_request_id            BIGINT NOT NULL AUTO_INCREMENT,
                                              outbound_order_id            BIGINT NOT NULL,

                                              return_request_no            VARCHAR(50) NOT NULL,
                                              return_status                ENUM(
                                                  'REQUESTED',
                                                  'APPROVED',
                                                  'REJECTED',
                                                  'IN_TRANSIT',
                                                  'RECEIVED',
                                                  'COMPLETED'
                                                  ) NOT NULL DEFAULT 'REQUESTED',
                                              return_reason_code           VARCHAR(50) NULL,
                                              return_reason_detail         VARCHAR(500) NULL,
                                              return_method                ENUM('COURIER', 'VISIT', 'OTHER') NOT NULL DEFAULT 'COURIER',
                                              requested_by_type            VARCHAR(50) NOT NULL DEFAULT 'CUSTOMER',
                                              requested_by_id              VARCHAR(100) NULL,
                                              requested_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              approved_at                  DATETIME NULL,
                                              rejected_at                  DATETIME NULL,
                                              received_at                  DATETIME NULL,
                                              completed_at                 DATETIME NULL,

                                              total_return_qty             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              total_return_amount          DECIMAL(18,4) NOT NULL DEFAULT 0,

                                              attributes_json              JSON NULL,
                                              created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                              PRIMARY KEY (return_request_id),
                                              UNIQUE KEY uq_return_request_no (return_request_no),
                                              KEY ix_return_request_order_id (outbound_order_id),
                                              KEY ix_return_request_status (return_status),
                                              KEY ix_return_request_requested_at (requested_at),

                                              CONSTRAINT fk_return_request_order
                                                  FOREIGN KEY (outbound_order_id) REFERENCES outbound_order(outbound_order_id),

                                              CONSTRAINT ck_return_request_amount CHECK (
                                                  total_return_qty >= 0
                                                      AND total_return_amount >= 0
                                                  )
) ENGINE=InnoDB;

-- =========================================================
-- 7. Return Request Line
-- =========================================================
CREATE TABLE IF NOT EXISTS return_request_line (
                                                   return_request_line_id       BIGINT NOT NULL AUTO_INCREMENT,
                                                   return_request_id            BIGINT NOT NULL,
                                                   outbound_order_line_id       BIGINT NOT NULL,

                                                   return_qty                   DECIMAL(18,4) NOT NULL,
                                                   return_amount                DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   return_reason_code           VARCHAR(50) NULL,
                                                   return_reason_detail         VARCHAR(500) NULL,

                                                   attributes_json              JSON NULL,
                                                   created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                   updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                   PRIMARY KEY (return_request_line_id),
                                                   UNIQUE KEY uq_return_request_line (return_request_id, outbound_order_line_id),
                                                   KEY ix_return_request_line_order_line_id (outbound_order_line_id),

                                                   CONSTRAINT fk_return_request_line_request
                                                       FOREIGN KEY (return_request_id) REFERENCES return_request(return_request_id),
                                                   CONSTRAINT fk_return_request_line_order_line
                                                       FOREIGN KEY (outbound_order_line_id) REFERENCES outbound_order_line(outbound_order_line_id),

                                                   CONSTRAINT ck_return_request_line_qty CHECK (
                                                       return_qty > 0
                                                           AND return_amount >= 0
                                                       )
) ENGINE=InnoDB;

-- =========================================================
-- 8. Shipment Header
-- =========================================================
CREATE TABLE IF NOT EXISTS shipment (
                                        shipment_id                  BIGINT NOT NULL AUTO_INCREMENT,
                                        outbound_order_id            BIGINT NOT NULL,

                                        shipment_no                  VARCHAR(50) NOT NULL,
                                        shipment_status              ENUM(
                                            'CREATED',
                                            'PICKING',
                                            'PICKED',
                                            'PACKING',
                                            'PACKED',
                                            'SHIPPED',
                                            'DELIVERED',
                                            'RETURNED',
                                            'CANCELLED'
                                            ) NOT NULL DEFAULT 'CREATED',

                                        fulfillment_center_code      VARCHAR(30) NOT NULL,
                                        carrier_code                 VARCHAR(50) NULL,
                                        service_level                VARCHAR(50) NULL,
                                        tracking_no                  VARCHAR(100) NULL,

                                        packed_at                    DATETIME NULL,
                                        shipped_at                   DATETIME NULL,
                                        delivered_at                 DATETIME NULL,
                                        returned_at                  DATETIME NULL,
                                        cancelled_at                 DATETIME NULL,

                                        total_shipment_qty           DECIMAL(18,4) NOT NULL DEFAULT 0,
                                        total_package_count          INT NOT NULL DEFAULT 0,
                                        total_weight                 DECIMAL(18,4) NULL,
                                        total_volume                 DECIMAL(18,4) NULL,

                                        attributes_json              JSON NULL,
                                        created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                        updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                        PRIMARY KEY (shipment_id),
                                        UNIQUE KEY uq_shipment_shipment_no (shipment_no),
                                        KEY ix_shipment_order_id (outbound_order_id),
                                        KEY ix_shipment_status (shipment_status),
                                        KEY ix_shipment_tracking_no (tracking_no),

                                        CONSTRAINT fk_shipment_order
                                            FOREIGN KEY (outbound_order_id) REFERENCES outbound_order(outbound_order_id),

                                        CONSTRAINT ck_shipment_qty CHECK (
                                            total_shipment_qty >= 0
                                                AND total_package_count >= 0
                                                AND (total_weight IS NULL OR total_weight >= 0)
                                                AND (total_volume IS NULL OR total_volume >= 0)
                                            )
) ENGINE=InnoDB;

-- =========================================================
-- 9. Shipment Package
-- 다중 패키지 출하 지원
-- =========================================================
CREATE TABLE IF NOT EXISTS shipment_package (
                                                shipment_package_id          BIGINT NOT NULL AUTO_INCREMENT,
                                                shipment_id                  BIGINT NOT NULL,

                                                package_no                   VARCHAR(50) NOT NULL,
                                                package_type                 VARCHAR(50) NULL,
                                                package_status               ENUM(
                                                    'CREATED',
                                                    'PACKED',
                                                    'SHIPPED',
                                                    'DELIVERED',
                                                    'RETURNED',
                                                    'CANCELLED'
                                                    ) NOT NULL DEFAULT 'CREATED',
                                                tracking_no                  VARCHAR(100) NULL,

                                                weight                       DECIMAL(18,4) NULL,
                                                volume                       DECIMAL(18,4) NULL,
                                                length_cm                    DECIMAL(18,4) NULL,
                                                width_cm                     DECIMAL(18,4) NULL,
                                                height_cm                    DECIMAL(18,4) NULL,

                                                packed_at                    DATETIME NULL,
                                                shipped_at                   DATETIME NULL,
                                                delivered_at                 DATETIME NULL,

                                                attributes_json              JSON NULL,
                                                created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                PRIMARY KEY (shipment_package_id),
                                                UNIQUE KEY uq_shipment_package_no (package_no),
                                                UNIQUE KEY uq_shipment_package_line (shipment_id, package_no),
                                                KEY ix_shipment_package_tracking_no (tracking_no),
                                                KEY ix_shipment_package_status (package_status),

                                                CONSTRAINT fk_shipment_package_shipment
                                                    FOREIGN KEY (shipment_id) REFERENCES shipment(shipment_id),

                                                CONSTRAINT ck_shipment_package_measure CHECK (
                                                    (weight IS NULL OR weight >= 0)
                                                        AND (volume IS NULL OR volume >= 0)
                                                        AND (length_cm IS NULL OR length_cm >= 0)
                                                        AND (width_cm IS NULL OR width_cm >= 0)
                                                        AND (height_cm IS NULL OR height_cm >= 0)
                                                    )
) ENGINE=InnoDB;

-- =========================================================
-- 10. Shipment Line
-- =========================================================
CREATE TABLE IF NOT EXISTS shipment_line (
                                             shipment_line_id             BIGINT NOT NULL AUTO_INCREMENT,
                                             shipment_id                  BIGINT NOT NULL,
                                             outbound_order_line_id       BIGINT NOT NULL,
                                             shipment_package_id          BIGINT NULL,

                                             line_no                      INT NOT NULL,
                                             sku_code                     VARCHAR(50) NOT NULL,
                                             sku_name                     VARCHAR(200) NULL,
                                             lot_no                       VARCHAR(100) NULL,

                                             shipped_qty                  DECIMAL(18,4) NOT NULL,
                                             uom                          VARCHAR(20) NOT NULL DEFAULT 'EA',
                                             from_location_code           VARCHAR(50) NULL,

                                             packed_at                    DATETIME NULL,
                                             shipped_at                   DATETIME NULL,

                                             attributes_json              JSON NULL,
                                             created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                             PRIMARY KEY (shipment_line_id),
                                             UNIQUE KEY uq_shipment_line (shipment_id, line_no),
                                             KEY ix_shipment_line_order_line_id (outbound_order_line_id),
                                             KEY ix_shipment_line_package_id (shipment_package_id),
                                             KEY ix_shipment_line_sku (sku_code),
                                             KEY ix_shipment_line_lot (lot_no),

                                             CONSTRAINT fk_shipment_line_shipment
                                                 FOREIGN KEY (shipment_id) REFERENCES shipment(shipment_id),
                                             CONSTRAINT fk_shipment_line_order_line
                                                 FOREIGN KEY (outbound_order_line_id) REFERENCES outbound_order_line(outbound_order_line_id),
                                             CONSTRAINT fk_shipment_line_package
                                                 FOREIGN KEY (shipment_package_id) REFERENCES shipment_package(shipment_package_id),

                                             CONSTRAINT ck_shipment_line_qty CHECK (
                                                 shipped_qty > 0
                                                 )
) ENGINE=InnoDB;

-- =========================================================
-- 11. Order Event
-- =========================================================
CREATE TABLE IF NOT EXISTS order_event (
                                           order_event_id               BIGINT NOT NULL AUTO_INCREMENT,
                                           outbound_order_id            BIGINT NOT NULL,
                                           outbound_order_line_id       BIGINT NULL,
                                           shipment_id                  BIGINT NULL,

                                           event_type                   VARCHAR(50) NOT NULL,
                                           event_status                 VARCHAR(50) NULL,
                                           event_id                     VARCHAR(100) NULL,
                                           event_at                     DATETIME NOT NULL,

                                           actor_type                   VARCHAR(50) NOT NULL DEFAULT 'SYSTEM',
                                           actor_id                     VARCHAR(100) NULL,
                                           message                      VARCHAR(500) NULL,
                                           attributes_json              JSON NULL,
                                           created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                           PRIMARY KEY (order_event_id),
                                           KEY ix_order_event_order (outbound_order_id),
                                           KEY ix_order_event_order_line (outbound_order_id, outbound_order_line_id),
                                           KEY ix_order_event_shipment (shipment_id),
                                           KEY ix_order_event_type_time (event_type, event_at),
                                           KEY ix_order_event_event_id (event_id),

                                           CONSTRAINT fk_order_event_order
                                               FOREIGN KEY (outbound_order_id) REFERENCES outbound_order(outbound_order_id),
                                           CONSTRAINT fk_order_event_order_line
                                               FOREIGN KEY (outbound_order_line_id) REFERENCES outbound_order_line(outbound_order_line_id),
                                           CONSTRAINT fk_order_event_shipment
                                               FOREIGN KEY (shipment_id) REFERENCES shipment(shipment_id)
) ENGINE=InnoDB;

-- =========================================================
-- 12. Current Order Summary View
-- =========================================================
CREATE OR REPLACE VIEW v_outbound_order_summary AS
SELECT
    o.outbound_order_id,
    o.order_no,
    o.external_order_no,
    o.sales_channel_code,
    o.order_type,
    o.order_status,
    o.payment_status,
    o.fulfillment_center_code,
    o.customer_code,
    o.customer_name,
    o.recipient_name,
    o.requested_ship_at,
    o.ordered_at,
    o.total_order_qty,
    o.total_allocated_qty,
    o.total_shipped_qty,
    o.total_cancelled_qty,
    o.item_amount,
    o.shipping_amount,
    o.tax_amount,
    o.net_order_amount,
    COUNT(DISTINCT l.outbound_order_line_id) AS line_count,
    COUNT(DISTINCT s.shipment_id) AS shipment_count
FROM outbound_order o
         LEFT JOIN outbound_order_line l
                   ON l.outbound_order_id = o.outbound_order_id
         LEFT JOIN shipment s
                   ON s.outbound_order_id = o.outbound_order_id
GROUP BY
    o.outbound_order_id,
    o.order_no,
    o.external_order_no,
    o.sales_channel_code,
    o.order_type,
    o.order_status,
    o.payment_status,
    o.fulfillment_center_code,
    o.customer_code,
    o.customer_name,
    o.recipient_name,
    o.requested_ship_at,
    o.ordered_at,
    o.total_order_qty,
    o.total_allocated_qty,
    o.total_shipped_qty,
    o.total_cancelled_qty,
    o.item_amount,
    o.shipping_amount,
    o.tax_amount,
    o.net_order_amount;
