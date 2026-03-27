package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.TemperatureType;
import inventory.domain.entity.enums.ZoneType;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "zone",
       uniqueConstraints = @UniqueConstraint(name = "uq_zone", columnNames = {"warehouse_id", "zone_code"}))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Zone extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "zone_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_zone_warehouse"))
    private Warehouse warehouse;

    @Column(name = "zone_code", nullable = false, length = 30)
    private String zoneCode;

    @Column(name = "zone_name", nullable = false, length = 200)
    private String zoneName;

    @Enumerated(EnumType.STRING)
    @Column(name = "zone_type", nullable = false, length = 20)
    private ZoneType zoneType;

    @Enumerated(EnumType.STRING)
    @Column(name = "temperature_type", length = 20)
    private TemperatureType temperatureType;

    @Column(name = "is_active", nullable = false)
    private Boolean active;
}