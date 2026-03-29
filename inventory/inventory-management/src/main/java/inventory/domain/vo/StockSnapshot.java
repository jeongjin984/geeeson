package inventory.domain.vo;

import inventory.domain.entity.InventoryStock;

import java.math.BigDecimal;

public record StockSnapshot(
        BigDecimal onHandQty,
        BigDecimal allocatedQty,
        BigDecimal pickedQty,
        BigDecimal availableQty
    ) {
        public static StockSnapshot from(InventoryStock stock) {
            return new StockSnapshot(
                stock.getOnHandQty(),
                stock.getAllocatedQty(),
                stock.getPickedQty(),
                stock.getAvailableQty()
            );
        }
    }