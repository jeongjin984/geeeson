USE payment_db;

-- =========================================================
-- PAYMENT DOMAIN FINAL DDL
-- - 도메인 내부 정합성 강화
-- - batch/simulation 같은 기술성 필드 제거
-- - 승인/캡처/취소/환불/정산까지 닫는 구조
-- - order / inventory / product 와 직접 FK 연결하지 않음
-- =========================================================

-- =========================================================
-- 1. Payment Header
-- 주문 단위 결제 집계
-- =========================================================
CREATE TABLE IF NOT EXISTS payment (
                                       payment_id                  BIGINT NOT NULL AUTO_INCREMENT,

                                       payment_no                  VARCHAR(50) NOT NULL,
                                       order_no                    VARCHAR(50) NOT NULL,
                                       merchant_id                 VARCHAR(50) NULL,
                                       sales_channel_code          VARCHAR(50) NULL,

                                       payment_type                ENUM(
                                           'AUTH_ONLY',
                                           'SALE',
                                           'PREAUTH',
                                           'MANUAL'
                                           ) NOT NULL DEFAULT 'SALE',
                                       payment_status              ENUM(
                                           'READY',
                                           'REQUESTED',
                                           'AUTHORIZED',
                                           'PARTIALLY_CAPTURED',
                                           'CAPTURED',
                                           'PARTIALLY_CANCELLED',
                                           'CANCELLED',
                                           'PARTIALLY_REFUNDED',
                                           'REFUNDED',
                                           'FAILED',
                                           'EXPIRED',
                                           'CLOSED'
                                           ) NOT NULL DEFAULT 'READY',

                                       payer_id                    VARCHAR(100) NULL,
                                       payer_name                  VARCHAR(200) NULL,
                                       payer_email                 VARCHAR(255) NULL,
                                       payer_phone                 VARCHAR(50) NULL,

                                       currency_code               CHAR(3) NOT NULL DEFAULT 'KRW',
                                       order_amount                DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       discount_amount             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       tax_amount                  DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       shipping_amount             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       payable_amount              DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       authorized_amount           DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       captured_amount             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       cancelled_amount            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       refunded_amount             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                       remaining_amount            DECIMAL(18,4) NOT NULL DEFAULT 0,

                                       requested_at                DATETIME NULL,
                                       authorized_at               DATETIME NULL,
                                       first_captured_at           DATETIME NULL,
                                       captured_at                 DATETIME NULL,
                                       cancelled_at                DATETIME NULL,
                                       refunded_at                 DATETIME NULL,
                                       failed_at                   DATETIME NULL,
                                       expired_at                  DATETIME NULL,
                                       closed_at                   DATETIME NULL,

                                       failure_code                VARCHAR(100) NULL,
                                       failure_message             VARCHAR(500) NULL,
                                       last_provider_code          VARCHAR(50) NULL,
                                       idempotency_key             VARCHAR(100) NULL,

                                       attributes_json             JSON NULL,
                                       created_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       updated_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                       PRIMARY KEY (payment_id),
                                       UNIQUE KEY uq_payment_no (payment_no),
                                       UNIQUE KEY uq_payment_idempotency_key (idempotency_key),
                                       KEY ix_payment_order_no (order_no),
                                       KEY ix_payment_status (payment_status),
                                       KEY ix_payment_requested_at (requested_at),
                                       KEY ix_payment_sales_channel_code (sales_channel_code),
                                       KEY ix_payment_merchant_id (merchant_id),

                                       CONSTRAINT ck_payment_amount CHECK (
                                           order_amount >= 0
                                               AND discount_amount >= 0
                                               AND tax_amount >= 0
                                               AND shipping_amount >= 0
                                               AND payable_amount >= 0
                                               AND authorized_amount >= 0
                                               AND captured_amount >= 0
                                               AND cancelled_amount >= 0
                                               AND refunded_amount >= 0
                                               AND remaining_amount >= 0
                                           )
) ENGINE=InnoDB;

-- =========================================================
-- 2. Payment Method
-- 결제수단별 상세
-- =========================================================
CREATE TABLE IF NOT EXISTS payment_method (
                                              payment_method_id           BIGINT NOT NULL AUTO_INCREMENT,
                                              payment_id                  BIGINT NOT NULL,

                                              method_seq                  INT NOT NULL DEFAULT 1,
                                              payment_method_type         ENUM(
                                                  'CARD',
                                                  'BANK_TRANSFER',
                                                  'VIRTUAL_ACCOUNT',
                                                  'MOBILE',
                                                  'POINT',
                                                  'COUPON',
                                                  'CASH',
                                                  'EASY_PAY',
                                                  'MANUAL'
                                                  ) NOT NULL,
                                              payment_method_status       ENUM(
                                                  'READY',
                                                  'AUTHORIZED',
                                                  'CAPTURED',
                                                  'PARTIALLY_CANCELLED',
                                                  'CANCELLED',
                                                  'PARTIALLY_REFUNDED',
                                                  'REFUNDED',
                                                  'FAILED',
                                                  'EXPIRED'
                                                  ) NOT NULL DEFAULT 'READY',

                                              provider_code               VARCHAR(50) NULL,
                                              provider_method_code        VARCHAR(50) NULL,
                                              provider_customer_key       VARCHAR(100) NULL,

                                              currency_code               CHAR(3) NOT NULL DEFAULT 'KRW',
                                              planned_amount              DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              authorized_amount           DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              captured_amount             DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              cancelled_amount            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                              refunded_amount             DECIMAL(18,4) NOT NULL DEFAULT 0,

                                              card_bin                    VARCHAR(20) NULL,
                                              card_last4                  VARCHAR(4) NULL,
                                              card_issuer_name            VARCHAR(100) NULL,
                                              card_acquirer_name          VARCHAR(100) NULL,
                                              card_installment_month      INT NULL,
                                              approval_no                 VARCHAR(100) NULL,

                                              bank_code                   VARCHAR(50) NULL,
                                              bank_account_masked         VARCHAR(100) NULL,
                                              virtual_account_no_masked   VARCHAR(100) NULL,
                                              virtual_account_holder_name VARCHAR(200) NULL,
                                              virtual_account_due_at      DATETIME NULL,

                                              point_type_code             VARCHAR(50) NULL,
                                              easy_pay_provider_code      VARCHAR(50) NULL,

                                              attributes_json             JSON NULL,
                                              created_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              updated_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                              PRIMARY KEY (payment_method_id),
                                              UNIQUE KEY uq_payment_method_seq (payment_id, method_seq),
                                              KEY ix_payment_method_payment_id (payment_id),
                                              KEY ix_payment_method_type (payment_method_type),
                                              KEY ix_payment_method_provider_code (provider_code),

                                              CONSTRAINT ck_payment_method_amount CHECK (
                                                  planned_amount >= 0
                                                      AND authorized_amount >= 0
                                                      AND captured_amount >= 0
                                                      AND cancelled_amount >= 0
                                                      AND refunded_amount >= 0
                                                  ),
                                              CONSTRAINT fk_payment_method_payment
                                                  FOREIGN KEY (payment_id) REFERENCES payment (payment_id)
) ENGINE=InnoDB;

-- =========================================================
-- 3. Payment Transaction
-- PG 승인 / 캡처 / 취소 / 환불 / 실패 단위
-- =========================================================
CREATE TABLE IF NOT EXISTS payment_transaction (
                                                   payment_transaction_id       BIGINT NOT NULL AUTO_INCREMENT,
                                                   payment_id                   BIGINT NOT NULL,
                                                   payment_method_id            BIGINT NULL,
                                                   parent_payment_transaction_id BIGINT NULL,

                                                   payment_txn_no               VARCHAR(50) NOT NULL,
                                                   parent_payment_txn_no        VARCHAR(50) NULL,

                                                   transaction_type             ENUM(
                                                       'AUTHORIZE',
                                                       'CAPTURE',
                                                       'CANCEL',
                                                       'REFUND',
                                                       'FAIL',
                                                       'EXPIRE',
                                                       'VOID',
                                                       'MANUAL_ADJUST'
                                                       ) NOT NULL,
                                                   transaction_status           ENUM(
                                                       'REQUESTED',
                                                       'PROCESSING',
                                                       'SUCCESS',
                                                       'FAILED',
                                                       'CANCELLED'
                                                       ) NOT NULL DEFAULT 'REQUESTED',

                                                   provider_code                VARCHAR(50) NULL,
                                                   provider_txn_id              VARCHAR(100) NULL,
                                                   provider_order_id            VARCHAR(100) NULL,
                                                   provider_merchant_id         VARCHAR(100) NULL,
                                                   approval_no                  VARCHAR(100) NULL,

                                                   currency_code                CHAR(3) NOT NULL DEFAULT 'KRW',
                                                   transaction_amount           DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   tax_amount                   DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                   fee_amount                   DECIMAL(18,4) NOT NULL DEFAULT 0,

                                                   requested_at                 DATETIME NULL,
                                                   processed_at                 DATETIME NULL,

                                                   failure_code                 VARCHAR(100) NULL,
                                                   failure_message              VARCHAR(500) NULL,

                                                   idempotency_key              VARCHAR(100) NULL,
                                                   provider_event_id            VARCHAR(100) NULL,
                                                   attributes_json              JSON NULL,
                                                   created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                   updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                   PRIMARY KEY (payment_transaction_id),
                                                   UNIQUE KEY uq_payment_transaction_payment_txn_no (payment_txn_no),
                                                   UNIQUE KEY uq_payment_transaction_idempotency_key (idempotency_key),
                                                   KEY ix_payment_transaction_payment_id (payment_id),
                                                   KEY ix_payment_transaction_payment_method_id (payment_method_id),
                                                   KEY ix_payment_transaction_parent_id (parent_payment_transaction_id),
                                                   KEY ix_payment_transaction_parent_no (parent_payment_txn_no),
                                                   KEY ix_payment_transaction_provider_txn_id (provider_txn_id),
                                                   KEY ix_payment_transaction_type_status (transaction_type, transaction_status),
                                                   KEY ix_payment_transaction_requested_at (requested_at),

                                                   CONSTRAINT ck_payment_transaction_amount CHECK (
                                                       transaction_amount >= 0
                                                           AND tax_amount >= 0
                                                           AND fee_amount >= 0
                                                       ),
                                                   CONSTRAINT fk_payment_transaction_payment
                                                       FOREIGN KEY (payment_id) REFERENCES payment (payment_id),
                                                   CONSTRAINT fk_payment_transaction_payment_method
                                                       FOREIGN KEY (payment_method_id) REFERENCES payment_method (payment_method_id),
                                                   CONSTRAINT fk_payment_transaction_parent
                                                       FOREIGN KEY (parent_payment_transaction_id) REFERENCES payment_transaction (payment_transaction_id)
) ENGINE=InnoDB;

-- =========================================================
-- 4. Payment Allocation
-- 주문 라인/배송비/세금 단위 금액 배분
-- 외부 order FK 없음. 업무키 사용
-- =========================================================
CREATE TABLE IF NOT EXISTS payment_allocation (
                                                  payment_allocation_id        BIGINT NOT NULL AUTO_INCREMENT,
                                                  payment_id                   BIGINT NOT NULL,
                                                  payment_transaction_id       BIGINT NULL,

                                                  order_no                     VARCHAR(50) NOT NULL,
                                                  order_line_no                INT NULL,
                                                  allocation_type              ENUM(
                                                      'ORDER',
                                                      'ORDER_LINE',
                                                      'SHIPPING_FEE',
                                                      'TAX',
                                                      'DISCOUNT',
                                                      'ETC'
                                                      ) NOT NULL DEFAULT 'ORDER_LINE',

                                                  currency_code                CHAR(3) NOT NULL DEFAULT 'KRW',
                                                  allocated_amount             DECIMAL(18,4) NOT NULL,

                                                  created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                  updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                  PRIMARY KEY (payment_allocation_id),
                                                  KEY ix_payment_allocation_payment_id (payment_id),
                                                  KEY ix_payment_allocation_payment_transaction_id (payment_transaction_id),
                                                  KEY ix_payment_allocation_order (order_no, order_line_no),
                                                  KEY ix_payment_allocation_type (allocation_type),

                                                  CONSTRAINT ck_payment_allocation_amount CHECK (allocated_amount >= 0),
                                                  CONSTRAINT fk_payment_allocation_payment
                                                      FOREIGN KEY (payment_id) REFERENCES payment (payment_id),
                                                  CONSTRAINT fk_payment_allocation_transaction
                                                      FOREIGN KEY (payment_transaction_id) REFERENCES payment_transaction (payment_transaction_id)
) ENGINE=InnoDB;

-- =========================================================
-- 5. Refund
-- 환불 요청/승인/처리 단위
-- =========================================================
CREATE TABLE IF NOT EXISTS refund (
                                      refund_id                    BIGINT NOT NULL AUTO_INCREMENT,
                                      payment_id                   BIGINT NOT NULL,

                                      refund_no                    VARCHAR(50) NOT NULL,
                                      order_no                     VARCHAR(50) NOT NULL,

                                      refund_status                ENUM(
                                          'REQUESTED',
                                          'APPROVED',
                                          'REJECTED',
                                          'PROCESSING',
                                          'PROCESSED',
                                          'FAILED',
                                          'CANCELLED'
                                          ) NOT NULL DEFAULT 'REQUESTED',
                                      refund_type                  ENUM(
                                          'FULL',
                                          'PARTIAL',
                                          'GOODWILL',
                                          'MANUAL'
                                          ) NOT NULL DEFAULT 'PARTIAL',
                                      refund_reason_code           VARCHAR(50) NULL,
                                      refund_reason_message        VARCHAR(500) NULL,

                                      currency_code                CHAR(3) NOT NULL DEFAULT 'KRW',
                                      refund_amount                DECIMAL(18,4) NOT NULL DEFAULT 0,
                                      tax_refund_amount            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                      shipping_refund_amount       DECIMAL(18,4) NOT NULL DEFAULT 0,

                                      requested_by_type            VARCHAR(50) NULL,
                                      requested_by_id              VARCHAR(100) NULL,
                                      approved_by_id               VARCHAR(100) NULL,

                                      requested_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      approved_at                  DATETIME NULL,
                                      processed_at                 DATETIME NULL,
                                      failed_at                    DATETIME NULL,
                                      cancelled_at                 DATETIME NULL,

                                      failure_code                 VARCHAR(100) NULL,
                                      failure_message              VARCHAR(500) NULL,

                                      attributes_json              JSON NULL,
                                      created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                      PRIMARY KEY (refund_id),
                                      UNIQUE KEY uq_refund_no (refund_no),
                                      KEY ix_refund_payment_id (payment_id),
                                      KEY ix_refund_order_no (order_no),
                                      KEY ix_refund_status (refund_status),
                                      KEY ix_refund_requested_at (requested_at),

                                      CONSTRAINT ck_refund_amount CHECK (
                                          refund_amount >= 0
                                              AND tax_refund_amount >= 0
                                              AND shipping_refund_amount >= 0
                                          ),
                                      CONSTRAINT fk_refund_payment
                                          FOREIGN KEY (payment_id) REFERENCES payment (payment_id)
) ENGINE=InnoDB;

-- =========================================================
-- 6. Refund Allocation
-- 라인 단위 환불 배분
-- =========================================================
CREATE TABLE IF NOT EXISTS refund_allocation (
                                                 refund_allocation_id         BIGINT NOT NULL AUTO_INCREMENT,
                                                 refund_id                    BIGINT NOT NULL,
                                                 payment_transaction_id       BIGINT NULL,

                                                 order_no                     VARCHAR(50) NOT NULL,
                                                 order_line_no                INT NULL,
                                                 allocation_type              ENUM(
                                                     'ORDER',
                                                     'ORDER_LINE',
                                                     'SHIPPING_FEE',
                                                     'TAX',
                                                     'DISCOUNT',
                                                     'ETC'
                                                     ) NOT NULL DEFAULT 'ORDER_LINE',

                                                 currency_code                CHAR(3) NOT NULL DEFAULT 'KRW',
                                                 refund_amount                DECIMAL(18,4) NOT NULL,

                                                 created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                 updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                 PRIMARY KEY (refund_allocation_id),
                                                 KEY ix_refund_allocation_refund_id (refund_id),
                                                 KEY ix_refund_allocation_payment_transaction_id (payment_transaction_id),
                                                 KEY ix_refund_allocation_order (order_no, order_line_no),
                                                 KEY ix_refund_allocation_type (allocation_type),

                                                 CONSTRAINT ck_refund_allocation_amount CHECK (refund_amount >= 0),
                                                 CONSTRAINT fk_refund_allocation_refund
                                                     FOREIGN KEY (refund_id) REFERENCES refund (refund_id),
                                                 CONSTRAINT fk_refund_allocation_transaction
                                                     FOREIGN KEY (payment_transaction_id) REFERENCES payment_transaction (payment_transaction_id)
) ENGINE=InnoDB;

-- =========================================================
-- 7. Payment Settlement
-- PG 정산 예정/확정/입금 관리
-- =========================================================
CREATE TABLE IF NOT EXISTS payment_settlement (
                                                  payment_settlement_id        BIGINT NOT NULL AUTO_INCREMENT,
                                                  payment_id                   BIGINT NOT NULL,

                                                  settlement_no                VARCHAR(50) NOT NULL,
                                                  settlement_status            ENUM(
                                                      'SCHEDULED',
                                                      'IN_PROGRESS',
                                                      'SETTLED',
                                                      'PARTIALLY_SETTLED',
                                                      'FAILED',
                                                      'DISPUTED'
                                                      ) NOT NULL DEFAULT 'SCHEDULED',

                                                  provider_code                VARCHAR(50) NULL,
                                                  statement_no                 VARCHAR(100) NULL,
                                                  deposit_account_masked       VARCHAR(100) NULL,

                                                  currency_code                CHAR(3) NOT NULL DEFAULT 'KRW',
                                                  gross_amount                 DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                  fee_amount                   DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                  fee_vat_amount               DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                  adjustment_amount            DECIMAL(18,4) NOT NULL DEFAULT 0,
                                                  net_settlement_amount        DECIMAL(18,4) NOT NULL DEFAULT 0,

                                                  scheduled_settlement_date    DATE NULL,
                                                  settled_at                   DATETIME NULL,
                                                  deposited_at                 DATETIME NULL,

                                                  failure_code                 VARCHAR(100) NULL,
                                                  failure_message              VARCHAR(500) NULL,
                                                  attributes_json              JSON NULL,
                                                  created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                  updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                  PRIMARY KEY (payment_settlement_id),
                                                  UNIQUE KEY uq_payment_settlement_no (settlement_no),
                                                  KEY ix_payment_settlement_payment_id (payment_id),
                                                  KEY ix_payment_settlement_status (settlement_status),
                                                  KEY ix_payment_settlement_provider_code (provider_code),
                                                  KEY ix_payment_settlement_date (scheduled_settlement_date),

                                                  CONSTRAINT ck_payment_settlement_amount CHECK (
                                                      gross_amount >= 0
                                                          AND fee_amount >= 0
                                                          AND fee_vat_amount >= 0
                                                          AND net_settlement_amount >= 0
                                                      ),
                                                  CONSTRAINT fk_payment_settlement_payment
                                                      FOREIGN KEY (payment_id) REFERENCES payment (payment_id)
) ENGINE=InnoDB;

-- =========================================================
-- 8. Payment Settlement Line
-- 정산 상세(거래/환불/수수료/조정)
-- =========================================================
CREATE TABLE IF NOT EXISTS payment_settlement_line (
                                                       payment_settlement_line_id   BIGINT NOT NULL AUTO_INCREMENT,
                                                       payment_settlement_id        BIGINT NOT NULL,
                                                       payment_transaction_id       BIGINT NULL,
                                                       refund_id                    BIGINT NULL,

                                                       line_seq                     INT NOT NULL,
                                                       settlement_line_type         ENUM(
                                                           'CAPTURE',
                                                           'CANCEL',
                                                           'REFUND',
                                                           'FEE',
                                                           'FEE_VAT',
                                                           'ADJUSTMENT'
                                                           ) NOT NULL,

                                                       reference_no                 VARCHAR(100) NULL,
                                                       currency_code                CHAR(3) NOT NULL DEFAULT 'KRW',
                                                       amount                       DECIMAL(18,4) NOT NULL,
                                                       occurred_at                  DATETIME NULL,
                                                       attributes_json              JSON NULL,
                                                       created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                       updated_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                       PRIMARY KEY (payment_settlement_line_id),
                                                       UNIQUE KEY uq_payment_settlement_line_seq (payment_settlement_id, line_seq),
                                                       KEY ix_payment_settlement_line_settlement_id (payment_settlement_id),
                                                       KEY ix_payment_settlement_line_payment_transaction_id (payment_transaction_id),
                                                       KEY ix_payment_settlement_line_refund_id (refund_id),
                                                       KEY ix_payment_settlement_line_type (settlement_line_type),

                                                       CONSTRAINT ck_payment_settlement_line_amount CHECK (amount <> 0),
                                                       CONSTRAINT fk_payment_settlement_line_settlement
                                                           FOREIGN KEY (payment_settlement_id) REFERENCES payment_settlement (payment_settlement_id),
                                                       CONSTRAINT fk_payment_settlement_line_transaction
                                                           FOREIGN KEY (payment_transaction_id) REFERENCES payment_transaction (payment_transaction_id),
                                                       CONSTRAINT fk_payment_settlement_line_refund
                                                           FOREIGN KEY (refund_id) REFERENCES refund (refund_id)
) ENGINE=InnoDB;

-- =========================================================
-- 9. Payment Event
-- =========================================================
CREATE TABLE IF NOT EXISTS payment_event (
                                             payment_event_id             BIGINT NOT NULL AUTO_INCREMENT,
                                             payment_id                   BIGINT NOT NULL,
                                             payment_transaction_id       BIGINT NULL,
                                             refund_id                    BIGINT NULL,
                                             payment_settlement_id        BIGINT NULL,

                                             order_no                     VARCHAR(50) NULL,
                                             event_type                   VARCHAR(50) NOT NULL,
                                             event_status                 VARCHAR(50) NULL,
                                             event_id                     VARCHAR(100) NULL,

                                             event_at                     DATETIME NOT NULL,
                                             actor_type                   VARCHAR(50) NOT NULL DEFAULT 'SYSTEM',
                                             actor_id                     VARCHAR(100) NULL,

                                             message                      VARCHAR(500) NULL,
                                             attributes_json              JSON NULL,
                                             created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                             PRIMARY KEY (payment_event_id),
                                             KEY ix_payment_event_payment_id (payment_id),
                                             KEY ix_payment_event_payment_transaction_id (payment_transaction_id),
                                             KEY ix_payment_event_refund_id (refund_id),
                                             KEY ix_payment_event_payment_settlement_id (payment_settlement_id),
                                             KEY ix_payment_event_order_no (order_no),
                                             KEY ix_payment_event_type_time (event_type, event_at),
                                             KEY ix_payment_event_event_id (event_id),

                                             CONSTRAINT fk_payment_event_payment
                                                 FOREIGN KEY (payment_id) REFERENCES payment (payment_id),
                                             CONSTRAINT fk_payment_event_transaction
                                                 FOREIGN KEY (payment_transaction_id) REFERENCES payment_transaction (payment_transaction_id),
                                             CONSTRAINT fk_payment_event_refund
                                                 FOREIGN KEY (refund_id) REFERENCES refund (refund_id),
                                             CONSTRAINT fk_payment_event_settlement
                                                 FOREIGN KEY (payment_settlement_id) REFERENCES payment_settlement (payment_settlement_id)
) ENGINE=InnoDB;

-- =========================================================
-- 10. View: Payment Summary
-- =========================================================
CREATE OR REPLACE VIEW v_payment_summary AS
SELECT
    p.payment_id,
    p.payment_no,
    p.order_no,
    p.payment_type,
    p.payment_status,
    p.currency_code,
    p.order_amount,
    p.payable_amount,
    p.authorized_amount,
    p.captured_amount,
    p.cancelled_amount,
    p.refunded_amount,
    p.remaining_amount,
    p.requested_at,
    p.authorized_at,
    p.captured_at,
    p.refunded_at,
    COALESCE(pm.method_count, 0) AS method_count,
    COALESCE(pt.transaction_count, 0) AS transaction_count,
    COALESCE(rf.refund_count, 0) AS refund_count,
    COALESCE(ps.settlement_count, 0) AS settlement_count,
    p.created_at,
    p.updated_at
FROM payment p
         LEFT JOIN (
    SELECT payment_id, COUNT(*) AS method_count
    FROM payment_method
    GROUP BY payment_id
) pm ON pm.payment_id = p.payment_id
         LEFT JOIN (
    SELECT payment_id, COUNT(*) AS transaction_count
    FROM payment_transaction
    GROUP BY payment_id
) pt ON pt.payment_id = p.payment_id
         LEFT JOIN (
    SELECT payment_id, COUNT(*) AS refund_count
    FROM refund
    GROUP BY payment_id
) rf ON rf.payment_id = p.payment_id
         LEFT JOIN (
    SELECT payment_id, COUNT(*) AS settlement_count
    FROM payment_settlement
    GROUP BY payment_id
) ps ON ps.payment_id = p.payment_id;
