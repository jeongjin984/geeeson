package inventory.domain.entity.view;

import com.querydsl.core.annotations.Immutable;
import inventory.domain.entity.enums.StockStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "v_inventory_balance")
@Immutable
@Getter
public class InventoryBalanceView {

    @Id
    @Column(name = "owner_id")
    private Long ownerId;

    @Column(name = "owner_code")
    private String ownerCode;

    @Column(name = "owner_name")
    private String ownerName;

    @Column(name = "warehouse_id")
    private Long warehouseId;

    @Column(name = "warehouse_code")
    private String warehouseCode;

    @Column(name = "location_id")
    private Long locationId;

    @Column(name = "location_code")
    private String locationCode;

    @Column(name = "item_id")
    private Long itemId;

    @Column(name = "item_code")
    private String itemCode;

    @Column(name = "item_name")
    private String itemName;

    @Column(name = "lot_id")
    private Long lotId;

    @Column(name = "lot_no")
    private String lotNo;

    @Column(name = "stock_status")
    private StockStatus stockStatus;

    @Column(name = "on_hand_qty")
    private BigDecimal onHandQty;

    @Column(name = "allocated_qty")
    private BigDecimal allocatedQty;

    @Column(name = "picked_qty")
    private BigDecimal pickedQty;

    @Column(name = "available_qty")
    private BigDecimal availableQty;

    @Column(name = "last_transaction_at")
    private LocalDateTime lastTransactionAt;
}