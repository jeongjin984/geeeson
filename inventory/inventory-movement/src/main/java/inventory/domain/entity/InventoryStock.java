package inventory.domain.entity;

import inventory.common.exceptions.DomainValidationException;
import inventory.common.exceptions.InsufficientStockException;
import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.StockStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "inventory_stock",
       uniqueConstraints = @UniqueConstraint(
               name = "uq_inventory_stock",
               columnNames = {"owner_id", "warehouse_id", "location_id", "item_id", "lot_id_normalized", "stock_status"}
       ))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
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
    private BigDecimal onHandQty;

    @Column(name = "allocated_qty", nullable = false, precision = 18, scale = 4)
    private BigDecimal allocatedQty;

    @Column(name = "picked_qty", nullable = false, precision = 18, scale = 4)
    private BigDecimal pickedQty;

    @Column(name = "available_qty", nullable = false, precision = 18, scale = 4)
    private BigDecimal availableQty;

    @Column(name = "last_transaction_at")
    private LocalDateTime lastTransactionAt;

    @Column(name = "lot_id_normalized", insertable = false, updatable = false)
    private Long lotIdNormalized;

    public void allocate(BigDecimal qty) {
        validatePositive(qty);

        if (availableQty.compareTo(qty) < 0) {
            throw new InsufficientStockException("Insufficient available stock");
        }

        this.allocatedQty = this.allocatedQty.add(qty);
        recalculateAvailable();
        validateNonNegative();
        this.lastTransactionAt = LocalDateTime.now();
    }

    public boolean canAllocate(BigDecimal qty) {
        return availableQty.compareTo(qty) >= 0;
    }

    public void deallocate(BigDecimal qty) {
        validatePositive(qty);

        if (allocatedQty.compareTo(qty) < 0) {
            throw new DomainValidationException("Allocated quantity is insufficient");
        }

        this.allocatedQty = this.allocatedQty.subtract(qty);
        recalculateAvailable();
        validateNonNegative();
        this.lastTransactionAt = LocalDateTime.now();
    }

    private void recalculateAvailable() {
        this.availableQty = this.onHandQty
            .subtract(this.allocatedQty)
            .subtract(this.pickedQty);
    }

    private void validatePositive(BigDecimal qty) {
        if (qty == null || qty.compareTo(BigDecimal.ZERO) <= 0) {
            throw new DomainValidationException("Quantity must be greater than zero");
        }
    }

    private void validateNonNegative() {
        if (onHandQty.compareTo(BigDecimal.ZERO) < 0
            || allocatedQty.compareTo(BigDecimal.ZERO) < 0
            || pickedQty.compareTo(BigDecimal.ZERO) < 0
            || availableQty.compareTo(BigDecimal.ZERO) < 0) {
            throw new DomainValidationException("Stock quantity cannot be negative");
        }
    }
}