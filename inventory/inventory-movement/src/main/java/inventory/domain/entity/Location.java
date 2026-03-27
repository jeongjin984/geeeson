package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.LocationType;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Entity
@Table(name = "location",
       uniqueConstraints = @UniqueConstraint(name = "uq_location", columnNames = {"warehouse_id", "location_code"}))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Location extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "location_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_location_warehouse"))
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_id",
            foreignKey = @ForeignKey(name = "fk_location_zone"))
    private Zone zone;

    @Column(name = "location_code", nullable = false, length = 50)
    private String locationCode;

    @Enumerated(EnumType.STRING)
    @Column(name = "location_type", nullable = false, length = 20)
    private LocationType locationType;

    @Column(name = "aisle", length = 20)
    private String aisle;

    @Column(name = "rack", length = 20)
    private String rack;

    @Column(name = "`level`", length = 20)
    private String locationLevel;

    @Column(name = "bin", length = 20)
    private String bin;

    @Column(name = "capacity_unit_qty", precision = 18, scale = 4)
    private BigDecimal capacityUnitQty;

    @Column(name = "capacity_volume", precision = 18, scale = 4)
    private BigDecimal capacityVolume;

    @Column(name = "capacity_weight", precision = 18, scale = 4)
    private BigDecimal capacityWeight;

    @Column(name = "is_pickable", nullable = false)
    private Boolean pickable;

    @Column(name = "is_active", nullable = false)
    private Boolean active;
}