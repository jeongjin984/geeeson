package inventory.domain.view;

import inventory.domain.entity.enums.StockStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record InventoryBalanceView (
    Long ownerId,
    String ownerCode,
    String ownerName,
    Long warehouseId,
    String warehouseCode,
    Long locationId,
    String locationCode,
    Long itemId,
    String itemCode,
    String itemName,
    Long lotId,
    String lotNo,
    StockStatus stockStatus,
    BigDecimal onHandQty,
    BigDecimal allocatedQty,
    BigDecimal pickedQty,
    BigDecimal availableQty,
    LocalDateTime lastTransactionAt
) {


}