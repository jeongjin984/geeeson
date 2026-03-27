package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "warehouse",
       uniqueConstraints = @UniqueConstraint(name = "uq_warehouse_code", columnNames = "warehouse_code"))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Warehouse extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "warehouse_id")
    private Long id;

    @Column(name = "warehouse_code", nullable = false, length = 30)
    private String warehouseCode;

    @Column(name = "warehouse_name", nullable = false, length = 200)
    private String warehouseName;

    @Column(name = "country_code", length = 2)
    private String countryCode;

    @Column(name = "timezone_name", length = 100)
    private String timezoneName;

    @Column(name = "is_active", nullable = false)
    private Boolean active;
}