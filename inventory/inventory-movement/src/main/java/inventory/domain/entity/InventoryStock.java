package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.StockStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "inventory_stock",
       uniqueConstraints = @UniqueConstraint(
               name = "uq_inventory_stock",
               columnNames = {"owner_id", "warehouse_id", "location_id", "item_id", "lot_id_normalized", "stock_status"}
       ))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InventoryStock extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inventory_stock_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_inventory_stock_owner"))
    private InventoryOwner owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_inventory_stock_warehouse"))
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_inventory_stock_location"))
    private Location location;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_inventory_stock_item"))
    private Item item;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lot_id",
            foreignKey = @ForeignKey(name = "fk_inventory_stock_lot"))
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

    @Column(name = "last_transaction_at")
    private java.time.LocalDateTime lastTransactionAt;

    @Column(name = "lot_id_normalized", insertable = false, updatable = false)
    private Long lotIdNormalized;
}