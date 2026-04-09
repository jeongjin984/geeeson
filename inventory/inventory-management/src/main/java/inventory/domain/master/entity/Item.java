package inventory.domain.master.entity;

import inventory.common.entity.BaseTimeEntity;
import inventory.common.enums.ItemType;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "item",
       uniqueConstraints = @UniqueConstraint(name = "uq_item_code", columnNames = "item_code"))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Item extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "item_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_item_owner"))
    private InventoryOwner owner;

    @Column(name = "item_code", nullable = false, length = 50)
    private String itemCode;

    @Column(name = "item_name", nullable = false, length = 200)
    private String itemName;

    @Lob
    @Column(name = "item_description")
    private String itemDescription;

    @Enumerated(EnumType.STRING)
    @Column(name = "item_type", nullable = false, length = 20)
    private ItemType itemType;

    @Column(name = "uom", nullable = false, length = 20)
    private String uom;

    @Column(name = "unit_weight", precision = 18, scale = 4)
    private java.math.BigDecimal unitWeight;

    @Column(name = "unit_volume", precision = 18, scale = 6)
    private java.math.BigDecimal unitVolume;

    @Column(name = "shelf_life_days")
    private Integer shelfLifeDays;

    @Column(name = "lot_controlled", nullable = false)
    private Boolean lotControlled;

    @Column(name = "serial_controlled", nullable = false)
    private Boolean serialControlled;

    @Column(name = "inbound_inspection_required", nullable = false)
    private Boolean inboundInspectionRequired;

    @Column(name = "abc_class", length = 1)
    private String abcClass;

    @Column(name = "is_active", nullable = false)
    private Boolean active;
}