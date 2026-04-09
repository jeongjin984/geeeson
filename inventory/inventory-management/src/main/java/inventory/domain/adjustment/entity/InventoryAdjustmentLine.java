package inventory.domain.adjustment.entity;

import inventory.common.entity.BaseTimeEntity;
import inventory.domain.master.entity.*;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "inventory_adjustment_line",
       uniqueConstraints = @UniqueConstraint(name = "uq_inventory_adjustment_line", columnNames = {"inventory_adjustment_id", "line_no"}))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InventoryAdjustmentLine extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inventory_adjustment_line_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inventory_adjustment_id", nullable = false)
    private InventoryAdjustment inventoryAdjustment;

    @Column(name = "line_no", nullable = false)
    private Integer lineNo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private InventoryOwner owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id", nullable = false)
    private Location location;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lot_id")
    private ItemLot lot;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "adjustment_reason_id", nullable = false)
    private AdjustmentReason adjustmentReason;

    @Column(name = "system_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal systemQty;

    @Column(name = "counted_qty", precision = 18, scale = 4)
    private java.math.BigDecimal countedQty;

    @Column(name = "adjusted_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal adjustedQty;
}