package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.HoldStatus;
import inventory.domain.entity.enums.HoldType;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "inventory_hold")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class InventoryHold extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inventory_hold_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private InventoryOwner owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false)
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id")
    private Location location;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lot_id")
    private ItemLot lot;

    @Enumerated(EnumType.STRING)
    @Column(name = "hold_type", nullable = false, length = 30)
    private HoldType holdType;

    @Column(name = "hold_reason", nullable = false, length = 255)
    private String holdReason;

    @Enumerated(EnumType.STRING)
    @Column(name = "hold_status", nullable = false, length = 20)
    private HoldStatus holdStatus;

    @Column(name = "held_qty", nullable = false, precision = 18, scale = 4)
    private BigDecimal heldQty;

    @Column(name = "released_qty", nullable = false, precision = 18, scale = 4)
    private BigDecimal releasedQty;

    @Column(name = "held_at", nullable = false)
    private LocalDateTime heldAt;

    @Column(name = "released_at")
    private LocalDateTime releasedAt;

    @Column(name = "created_by", nullable = false, length = 100)
    private String createdBy;

    @Column(name = "released_by", length = 100)
    private String releasedBy;

    public void release(BigDecimal qty, String releasedBy) {
        this.releasedQty = this.releasedQty.add(qty);
        if (this.releasedQty.compareTo(this.heldQty) >= 0) {
            this.holdStatus = HoldStatus.RELEASED;
            this.releasedAt = LocalDateTime.now();
            this.releasedBy = releasedBy;
        }
    }
}