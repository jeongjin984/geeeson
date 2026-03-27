package inventory.domain.entity;

import inventory.domain.entity.enums.StockStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "inventory_snapshot")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InventorySnapshot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inventory_snapshot_id")
    private Long id;

    @Column(name = "snapshot_at", nullable = false)
    private java.time.LocalDateTime snapshotAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private InventoryOwner owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false)
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id", nullable = false)
    private Location location;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lot_id")
    private ItemLot lot;

    @Enumerated(EnumType.STRING)
    @Column(name = "stock_status", nullable = false, length = 20)
    private StockStatus stockStatus;

    @Column(name = "on_hand_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal onHandQty;

    @Column(name = "allocated_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal allocatedQty;

    @Column(name = "picked_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal pickedQty;

    @Column(name = "available_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal availableQty;

    @Column(name = "created_at", nullable = false, updatable = false)
    private java.time.LocalDateTime createdAt;
}