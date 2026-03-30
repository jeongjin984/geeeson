package inventory.domain.entity;

import inventory.domain.entity.enums.StockStatus;
import inventory.domain.entity.enums.TransactionReferenceType;
import inventory.domain.entity.enums.TransactionType;
import inventory.domain.service.ReserveInventoryService;
import inventory.domain.vo.StockSnapshot;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@Entity
@Table(name = "inventory_transaction")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class InventoryTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inventory_transaction_id")
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", nullable = false, length = 30)
    private TransactionType transactionType;

    @Enumerated(EnumType.STRING)
    @Column(name = "reference_type", nullable = false, length = 20)
    private TransactionReferenceType referenceType;

    @Column(name = "reference_no", length = 100)
    private String referenceNo;

    @Column(name = "reference_line_no", length = 50)
    private String referenceLineNo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false)
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private InventoryOwner owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "from_location_id")
    private Location fromLocation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "to_location_id")
    private Location toLocation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lot_id")
    private ItemLot lot;

    @Enumerated(EnumType.STRING)
    @Column(name = "stock_status_before", length = 20)
    private StockStatus stockStatusBefore;

    @Enumerated(EnumType.STRING)
    @Column(name = "stock_status_after", length = 20)
    private StockStatus stockStatusAfter;

    @Column(name = "quantity", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal quantity;

    @Column(name = "uom", nullable = false, length = 20)
    private String uom;

    @Column(name = "on_hand_before", precision = 18, scale = 4)
    private java.math.BigDecimal onHandBefore;

    @Column(name = "on_hand_after", precision = 18, scale = 4)
    private java.math.BigDecimal onHandAfter;

    @Column(name = "allocated_before", precision = 18, scale = 4)
    private java.math.BigDecimal allocatedBefore;

    @Column(name = "allocated_after", precision = 18, scale = 4)
    private java.math.BigDecimal allocatedAfter;

    @Column(name = "available_before", precision = 18, scale = 4)
    private java.math.BigDecimal availableBefore;

    @Column(name = "available_after", precision = 18, scale = 4)
    private java.math.BigDecimal availableAfter;

    @Column(name = "transaction_at", nullable = false)
    private java.time.LocalDateTime transactionAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private java.time.LocalDateTime createdAt;

    @Column(name = "created_by", nullable = false, length = 100)
    private String createdBy;

    @Lob
    @Column(name = "remark")
    private String remark;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "attributes_json")
    private Map<String, Object> attributesJson;

    public static InventoryTransaction allocate(
        InventoryReservation reservation,
        InventoryStock stock,
        StockSnapshot before,
        StockSnapshot after
    ) {
        return InventoryTransaction.builder()
            .transactionType(TransactionType.ALLOCATE)
            .referenceType(TransactionReferenceType.MANUAL)
            .referenceNo(reservation.getReferenceNo())
            .referenceLineNo(reservation.getReferenceLineNo())
            .warehouse(stock.getWarehouse())
            .owner(stock.getOwner())
            .fromLocation(stock.getLocation())
            .toLocation(null)
            .item(stock.getItem())
            .lot(stock.getLot())
            .stockStatusBefore(stock.getStockStatus())
            .stockStatusAfter(stock.getStockStatus())
            .quantity(reservation.getReservedQty())
            .uom(stock.getItem().getUom())
            .onHandBefore(before.onHandQty())
            .onHandAfter(after.onHandQty())
            .allocatedBefore(before.allocatedQty())
            .allocatedAfter(after.allocatedQty())
            .availableBefore(before.availableQty())
            .availableAfter(after.availableQty())
            .transactionAt(LocalDateTime.now())
            .createdBy("SYSTEM")
            .build();
    }

    public static InventoryTransaction deallocate(
        InventoryReservation reservation,
        InventoryStock stock,
        StockSnapshot before,
        StockSnapshot after,
        BigDecimal qty
    ) {
        return InventoryTransaction.builder()
            .transactionType(TransactionType.DEALLOCATE)
            .referenceType(TransactionReferenceType.MANUAL)
            .referenceNo(reservation.getReferenceNo())
            .referenceLineNo(reservation.getReferenceLineNo())
            .warehouse(stock.getWarehouse())
            .owner(stock.getOwner())
            .fromLocation(stock.getLocation())
            .toLocation(null)
            .item(stock.getItem())
            .lot(stock.getLot())
            .stockStatusBefore(stock.getStockStatus())
            .stockStatusAfter(stock.getStockStatus())
            .quantity(qty)
            .uom(stock.getItem().getUom())
            .onHandBefore(before.onHandQty())
            .onHandAfter(after.onHandQty())
            .allocatedBefore(before.allocatedQty())
            .allocatedAfter(after.allocatedQty())
            .availableBefore(before.availableQty())
            .availableAfter(after.availableQty())
            .transactionAt(LocalDateTime.now())
            .createdBy("SYSTEM")
            .build();
    }
}