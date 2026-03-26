USE product_db;

-- =========================================================
-- PRODUCT DOMAIN FINAL
-- inventory / order / payment 와 직접 FK로 연결하지 않음
-- MySQL 8 기준
-- =========================================================

SET NAMES utf8mb4;

-- =========================================================
-- 1. Brand
-- =========================================================
CREATE TABLE IF NOT EXISTS brand (
                                     brand_id                 BIGINT NOT NULL AUTO_INCREMENT,
                                     brand_code               VARCHAR(50) NOT NULL,
                                     brand_name               VARCHAR(200) NOT NULL,
                                     brand_name_en            VARCHAR(200) NULL,
                                     brand_status             ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
                                     country_code             VARCHAR(2) NULL,
                                     description              TEXT NULL,
                                     attributes_json          JSON NULL,
                                     created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                     updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                     PRIMARY KEY (brand_id),
                                     UNIQUE KEY uq_brand_code (brand_code),
                                     KEY ix_brand_status (brand_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 2. Category
-- adjacency list + FK 기반 계층
-- =========================================================
CREATE TABLE IF NOT EXISTS category (
                                        category_id              BIGINT NOT NULL AUTO_INCREMENT,
                                        category_code            VARCHAR(50) NOT NULL,
                                        category_name            VARCHAR(200) NOT NULL,
                                        parent_category_id       BIGINT NULL,
                                        category_level           INT NOT NULL DEFAULT 1,
                                        sort_order               INT NOT NULL DEFAULT 0,
                                        category_status          ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
                                        is_leaf                  TINYINT(1) NOT NULL DEFAULT 1,
                                        attributes_json          JSON NULL,
                                        created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                        updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                        PRIMARY KEY (category_id),
                                        UNIQUE KEY uq_category_code (category_code),
                                        KEY ix_category_parent_id (parent_category_id),
                                        KEY ix_category_status (category_status),
                                        CONSTRAINT fk_category_parent
                                            FOREIGN KEY (parent_category_id) REFERENCES category(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 3. Product
-- 상품 마스터
-- =========================================================
CREATE TABLE IF NOT EXISTS product (
                                       product_id               BIGINT NOT NULL AUTO_INCREMENT,
                                       product_code             VARCHAR(50) NOT NULL,
                                       product_name             VARCHAR(200) NOT NULL,
                                       product_name_en          VARCHAR(200) NULL,
                                       product_type             ENUM('NORMAL','BUNDLE','SERVICE','DIGITAL') NOT NULL DEFAULT 'NORMAL',
                                       product_status           ENUM('DRAFT','READY','ACTIVE','INACTIVE','DISCONTINUED') NOT NULL DEFAULT 'DRAFT',
                                       brand_id                 BIGINT NULL,
                                       product_description      TEXT NULL,
                                       search_keywords          VARCHAR(500) NULL,
                                       tax_type                 ENUM('TAXABLE','ZERO_RATED','TAX_FREE') NOT NULL DEFAULT 'TAXABLE',
                                       adult_only_yn            TINYINT(1) NOT NULL DEFAULT 0,
                                       returnable_yn            TINYINT(1) NOT NULL DEFAULT 1,
                                       exchangeable_yn          TINYINT(1) NOT NULL DEFAULT 1,
                                       origin_country_code      VARCHAR(2) NULL,
                                       manufacturer_name        VARCHAR(200) NULL,
                                       hs_code                  VARCHAR(30) NULL,
                                       sell_start_at            DATETIME NULL,
                                       sell_end_at              DATETIME NULL,
                                       approved_at              DATETIME NULL,
                                       discontinued_at          DATETIME NULL,
                                       attributes_json          JSON NULL,
                                       created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                       PRIMARY KEY (product_id),
                                       UNIQUE KEY uq_product_code (product_code),
                                       KEY ix_product_status (product_status),
                                       KEY ix_product_brand_id (brand_id),
                                       KEY ix_product_sell_period (sell_start_at, sell_end_at),
                                       CONSTRAINT fk_product_brand
                                           FOREIGN KEY (brand_id) REFERENCES brand(brand_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 4. Product Category Mapping
-- 멀티 카테고리 대응
-- =========================================================
CREATE TABLE IF NOT EXISTS product_category_map (
                                                    product_category_map_id  BIGINT NOT NULL AUTO_INCREMENT,
                                                    product_id               BIGINT NOT NULL,
                                                    category_id              BIGINT NOT NULL,
                                                    is_primary               TINYINT(1) NOT NULL DEFAULT 0,
                                                    sort_order               INT NOT NULL DEFAULT 0,
                                                    created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                    PRIMARY KEY (product_category_map_id),
                                                    UNIQUE KEY uq_product_category_map (product_id, category_id),
                                                    KEY ix_product_category_map_category (category_id),
                                                    KEY ix_product_category_map_primary (product_id, is_primary),
                                                    CONSTRAINT fk_product_category_map_product
                                                        FOREIGN KEY (product_id) REFERENCES product(product_id),
                                                    CONSTRAINT fk_product_category_map_category
                                                        FOREIGN KEY (category_id) REFERENCES category(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 5. Product Media
-- 이미지/영상/문서
-- =========================================================
CREATE TABLE IF NOT EXISTS product_media (
                                             product_media_id         BIGINT NOT NULL AUTO_INCREMENT,
                                             product_id               BIGINT NOT NULL,
                                             media_type               ENUM('IMAGE','VIDEO','DOCUMENT') NOT NULL DEFAULT 'IMAGE',
                                             media_role               ENUM('MAIN','THUMBNAIL','DETAIL','GALLERY','SIZE_GUIDE','MANUAL') NOT NULL DEFAULT 'DETAIL',
                                             media_url                VARCHAR(1000) NOT NULL,
                                             alt_text                 VARCHAR(255) NULL,
                                             sort_order               INT NOT NULL DEFAULT 0,
                                             active_yn                TINYINT(1) NOT NULL DEFAULT 1,
                                             created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                             PRIMARY KEY (product_media_id),
                                             KEY ix_product_media_product (product_id),
                                             KEY ix_product_media_role (media_role),
                                             CONSTRAINT fk_product_media_product
                                                 FOREIGN KEY (product_id) REFERENCES product(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 6. Product SKU
-- 판매 / 출고 / 재고 연계의 기준 식별자
-- =========================================================
CREATE TABLE IF NOT EXISTS product_sku (
                                           product_sku_id           BIGINT NOT NULL AUTO_INCREMENT,
                                           product_id               BIGINT NOT NULL,
                                           sku_code                 VARCHAR(50) NOT NULL,
                                           sku_name                 VARCHAR(200) NOT NULL,
                                           sku_status               ENUM('READY','ACTIVE','INACTIVE','DISCONTINUED') NOT NULL DEFAULT 'READY',
                                           barcode                  VARCHAR(100) NULL,
                                           external_sku_code        VARCHAR(100) NULL,
                                           option_summary           VARCHAR(500) NULL,
                                           uom                      VARCHAR(20) NOT NULL DEFAULT 'EA',
                                           pack_unit_qty            DECIMAL(18,4) NULL,
                                           unit_weight              DECIMAL(18,4) NULL,
                                           unit_volume              DECIMAL(18,6) NULL,
                                           width_cm                 DECIMAL(18,4) NULL,
                                           height_cm                DECIMAL(18,4) NULL,
                                           depth_cm                 DECIMAL(18,4) NULL,
                                           currency_code            VARCHAR(3) NOT NULL DEFAULT 'KRW',
                                           list_price               DECIMAL(18,4) NOT NULL DEFAULT 0,
                                           sale_price               DECIMAL(18,4) NOT NULL DEFAULT 0,
                                           cost_price               DECIMAL(18,4) NOT NULL DEFAULT 0,
                                           sellable_yn              TINYINT(1) NOT NULL DEFAULT 1,
                                           returnable_yn            TINYINT(1) NOT NULL DEFAULT 1,
                                           safety_stock_qty         DECIMAL(18,4) NULL,
                                           effective_from           DATETIME NULL,
                                           effective_to             DATETIME NULL,
                                           attributes_json          JSON NULL,
                                           created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                           updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                           PRIMARY KEY (product_sku_id),
                                           UNIQUE KEY uq_product_sku_code (sku_code),
                                           UNIQUE KEY uq_product_external_sku_code (external_sku_code),
                                           KEY ix_product_sku_product_id (product_id),
                                           KEY ix_product_sku_status (sku_status),
                                           KEY ix_product_sku_barcode (barcode),
                                           KEY ix_product_sku_effective_period (effective_from, effective_to),
                                           CONSTRAINT fk_product_sku_product
                                               FOREIGN KEY (product_id) REFERENCES product(product_id),
                                           CONSTRAINT ck_product_sku_prices CHECK (
                                               list_price >= 0 AND sale_price >= 0 AND cost_price >= 0
                                               )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 7. Product Option Definition
-- =========================================================
CREATE TABLE IF NOT EXISTS product_option (
                                              product_option_id        BIGINT NOT NULL AUTO_INCREMENT,
                                              product_id               BIGINT NOT NULL,
                                              option_code              VARCHAR(50) NOT NULL,
                                              option_name              VARCHAR(100) NOT NULL,
                                              option_type              ENUM('SELECT','TEXT','NUMBER') NOT NULL DEFAULT 'SELECT',
                                              required_yn              TINYINT(1) NOT NULL DEFAULT 0,
                                              variant_axis_yn          TINYINT(1) NOT NULL DEFAULT 1,
                                              sort_order               INT NOT NULL DEFAULT 0,
                                              attributes_json          JSON NULL,
                                              created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                              PRIMARY KEY (product_option_id),
                                              UNIQUE KEY uq_product_option (product_id, option_code),
                                              KEY ix_product_option_product_id (product_id),
                                              CONSTRAINT fk_product_option_product
                                                  FOREIGN KEY (product_id) REFERENCES product(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 8. Product Option Value
-- =========================================================
CREATE TABLE IF NOT EXISTS product_option_value (
                                                    product_option_value_id  BIGINT NOT NULL AUTO_INCREMENT,
                                                    product_option_id        BIGINT NOT NULL,
                                                    option_value_code        VARCHAR(50) NOT NULL,
                                                    option_value_name        VARCHAR(100) NOT NULL,
                                                    sort_order               INT NOT NULL DEFAULT 0,
                                                    active_yn                TINYINT(1) NOT NULL DEFAULT 1,
                                                    attributes_json          JSON NULL,
                                                    created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                    updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                                    PRIMARY KEY (product_option_value_id),
                                                    UNIQUE KEY uq_product_option_value (product_option_id, option_value_code),
                                                    KEY ix_product_option_value_option_id (product_option_id),
                                                    CONSTRAINT fk_product_option_value_option
                                                        FOREIGN KEY (product_option_id) REFERENCES product_option(product_option_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 9. SKU Option Mapping
-- SKU가 어떤 옵션 조합인지 표현
-- =========================================================
CREATE TABLE IF NOT EXISTS product_sku_option_map (
                                                      product_sku_option_map_id BIGINT NOT NULL AUTO_INCREMENT,
                                                      product_sku_id            BIGINT NOT NULL,
                                                      product_option_id         BIGINT NOT NULL,
                                                      product_option_value_id   BIGINT NOT NULL,
                                                      created_at                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                      PRIMARY KEY (product_sku_option_map_id),
                                                      UNIQUE KEY uq_product_sku_option_map (product_sku_id, product_option_id),
                                                      KEY ix_product_sku_option_map_option_value (product_option_value_id),
                                                      CONSTRAINT fk_product_sku_option_map_sku
                                                          FOREIGN KEY (product_sku_id) REFERENCES product_sku(product_sku_id),
                                                      CONSTRAINT fk_product_sku_option_map_option
                                                          FOREIGN KEY (product_option_id) REFERENCES product_option(product_option_id),
                                                      CONSTRAINT fk_product_sku_option_map_option_value
                                                          FOREIGN KEY (product_option_value_id) REFERENCES product_option_value(product_option_value_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 10. Product Price (current)
-- 현재 유효 가격
-- =========================================================
CREATE TABLE IF NOT EXISTS product_price (
                                             product_price_id         BIGINT NOT NULL AUTO_INCREMENT,
                                             product_sku_id           BIGINT NOT NULL,
                                             price_type               ENUM('LIST','SALE','COST') NOT NULL DEFAULT 'SALE',
                                             sales_channel_code       VARCHAR(50) NOT NULL DEFAULT 'DEFAULT',
                                             currency_code            VARCHAR(3) NOT NULL DEFAULT 'KRW',
                                             price_amount             DECIMAL(18,4) NOT NULL,
                                             tax_included_yn          TINYINT(1) NOT NULL DEFAULT 1,
                                             effective_from           DATETIME NOT NULL,
                                             effective_to             DATETIME NULL,
                                             active_yn                TINYINT(1) NOT NULL DEFAULT 1,
                                             created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                             PRIMARY KEY (product_price_id),
                                             UNIQUE KEY uq_product_price_current (product_sku_id, price_type, sales_channel_code, effective_from),
                                             KEY ix_product_price_lookup (product_sku_id, price_type, sales_channel_code, active_yn),
                                             KEY ix_product_price_effective (effective_from, effective_to),
                                             CONSTRAINT fk_product_price_sku
                                                 FOREIGN KEY (product_sku_id) REFERENCES product_sku(product_sku_id),
                                             CONSTRAINT ck_product_price_amount CHECK (price_amount >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 11. Product Price History
-- 가격 변경 이력 감사용
-- =========================================================
CREATE TABLE IF NOT EXISTS product_price_history (
                                                     product_price_history_id BIGINT NOT NULL AUTO_INCREMENT,
                                                     product_sku_id           BIGINT NOT NULL,
                                                     price_type               ENUM('LIST','SALE','COST') NOT NULL DEFAULT 'SALE',
                                                     sales_channel_code       VARCHAR(50) NOT NULL DEFAULT 'DEFAULT',
                                                     currency_code            VARCHAR(3) NOT NULL DEFAULT 'KRW',
                                                     previous_price_amount    DECIMAL(18,4) NULL,
                                                     new_price_amount         DECIMAL(18,4) NOT NULL,
                                                     tax_included_yn          TINYINT(1) NOT NULL DEFAULT 1,
                                                     reason_code              VARCHAR(50) NULL,
                                                     changed_at               DATETIME NOT NULL,
                                                     changed_by               VARCHAR(100) NULL,
                                                     effective_from           DATETIME NOT NULL,
                                                     effective_to             DATETIME NULL,
                                                     attributes_json          JSON NULL,
                                                     created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                     PRIMARY KEY (product_price_history_id),
                                                     KEY ix_product_price_history_sku (product_sku_id),
                                                     KEY ix_product_price_history_changed_at (changed_at),
                                                     KEY ix_product_price_history_effective (effective_from, effective_to),
                                                     CONSTRAINT fk_product_price_history_sku
                                                         FOREIGN KEY (product_sku_id) REFERENCES product_sku(product_sku_id),
                                                     CONSTRAINT ck_product_price_history_amount CHECK (
                                                         new_price_amount >= 0 AND (previous_price_amount IS NULL OR previous_price_amount >= 0)
                                                         )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 12. Product Channel Listing
-- 채널별 판매상태 / 노출상태 / 판매기간
-- =========================================================
CREATE TABLE IF NOT EXISTS product_channel_listing (
                                                       product_channel_listing_id BIGINT NOT NULL AUTO_INCREMENT,
                                                       product_id                 BIGINT NOT NULL,
                                                       sales_channel_code         VARCHAR(50) NOT NULL,
                                                       listing_status             ENUM('DRAFT','ACTIVE','INACTIVE','SUSPENDED','ENDED') NOT NULL DEFAULT 'DRAFT',
                                                       display_name               VARCHAR(200) NULL,
                                                       display_description        TEXT NULL,
                                                       visible_yn                 TINYINT(1) NOT NULL DEFAULT 1,
                                                       purchasable_yn             TINYINT(1) NOT NULL DEFAULT 1,
                                                       display_start_at           DATETIME NULL,
                                                       display_end_at             DATETIME NULL,
                                                       sell_start_at              DATETIME NULL,
                                                       sell_end_at                DATETIME NULL,
                                                       created_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                       updated_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                                       PRIMARY KEY (product_channel_listing_id),
                                                       UNIQUE KEY uq_product_channel_listing (product_id, sales_channel_code),
                                                       KEY ix_product_channel_listing_status (listing_status),
                                                       KEY ix_product_channel_listing_period (display_start_at, display_end_at),
                                                       CONSTRAINT fk_product_channel_listing_product
                                                           FOREIGN KEY (product_id) REFERENCES product(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 13. Bundle Component
-- 번들 상품 구성요소
-- =========================================================
CREATE TABLE IF NOT EXISTS product_bundle_component (
                                                        product_bundle_component_id BIGINT NOT NULL AUTO_INCREMENT,
                                                        bundle_product_id           BIGINT NOT NULL,
                                                        component_product_sku_id    BIGINT NOT NULL,
                                                        component_qty               DECIMAL(18,4) NOT NULL DEFAULT 1,
                                                        sort_order                  INT NOT NULL DEFAULT 0,
                                                        created_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                        updated_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                                        PRIMARY KEY (product_bundle_component_id),
                                                        UNIQUE KEY uq_product_bundle_component (bundle_product_id, component_product_sku_id),
                                                        KEY ix_product_bundle_component_sku (component_product_sku_id),
                                                        CONSTRAINT fk_product_bundle_component_bundle_product
                                                            FOREIGN KEY (bundle_product_id) REFERENCES product(product_id),
                                                        CONSTRAINT fk_product_bundle_component_component_sku
                                                            FOREIGN KEY (component_product_sku_id) REFERENCES product_sku(product_sku_id),
                                                        CONSTRAINT ck_product_bundle_component_qty CHECK (component_qty > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 14. Product Event
-- =========================================================
CREATE TABLE IF NOT EXISTS product_event (
                                             product_event_id          BIGINT NOT NULL AUTO_INCREMENT,
                                             product_id                BIGINT NULL,
                                             product_sku_id            BIGINT NULL,
                                             event_type                VARCHAR(50) NOT NULL,
                                             event_status              VARCHAR(50) NULL,
                                             event_id                  VARCHAR(100) NULL,
                                             event_at                  DATETIME NOT NULL,
                                             actor_type                VARCHAR(50) NOT NULL DEFAULT 'SYSTEM',
                                             actor_id                  VARCHAR(100) NULL,
                                             message                   VARCHAR(500) NULL,
                                             attributes_json           JSON NULL,
                                             created_at                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             PRIMARY KEY (product_event_id),
                                             KEY ix_product_event_product_id (product_id),
                                             KEY ix_product_event_product_sku_id (product_sku_id),
                                             KEY ix_product_event_type_time (event_type, event_at),
                                             KEY ix_product_event_event_id (event_id),
                                             CONSTRAINT fk_product_event_product
                                                 FOREIGN KEY (product_id) REFERENCES product(product_id),
                                             CONSTRAINT fk_product_event_product_sku
                                                 FOREIGN KEY (product_sku_id) REFERENCES product_sku(product_sku_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 15. View
-- =========================================================
DROP VIEW IF EXISTS v_product_catalog_summary;

CREATE VIEW v_product_catalog_summary AS
SELECT
    p.product_id,
    p.product_code,
    p.product_name,
    p.product_type,
    p.product_status,
    b.brand_code,
    b.brand_name,
    COUNT(DISTINCT ps.product_sku_id) AS sku_count,
    COUNT(DISTINCT pcm.category_id) AS category_count,
    MIN(ps.sale_price) AS min_sale_price,
    MAX(ps.sale_price) AS max_sale_price,
    MAX(p.updated_at) AS product_updated_at
FROM product p
         LEFT JOIN brand b
                   ON p.brand_id = b.brand_id
         LEFT JOIN product_sku ps
                   ON p.product_id = ps.product_id
         LEFT JOIN product_category_map pcm
                   ON p.product_id = pcm.product_id
GROUP BY
    p.product_id,
    p.product_code,
    p.product_name,
    p.product_type,
    p.product_status,
    b.brand_code,
    b.brand_name;
