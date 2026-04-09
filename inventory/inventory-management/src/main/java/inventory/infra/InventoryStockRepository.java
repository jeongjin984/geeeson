package inventory.infra;

import inventory.common.enums.StockStatus;
import inventory.domain.master.entity.*;
import inventory.domain.stock.entity.InventoryStock;
import inventory.infra.jpa.InventoryStockJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class InventoryStockRepository {
    private final InventoryStockJpaRepository inventoryStockJpaRepository;

    public Optional<InventoryStock> findById(Long id) {
        return inventoryStockJpaRepository.findById(id);
    }

    public Optional<InventoryStock> findForUpdateByLocation(
        InventoryOwner owner,
        Warehouse warehouse,
        Location location,
        Item item,
        ItemLot lot,
        StockStatus stockStatus
    ) {
        return inventoryStockJpaRepository.findForUpdateByLocation(owner, warehouse, location, item, lot, stockStatus);
    }

    public List<InventoryStock> findAllForUpdateWithoutLocation(
        InventoryOwner owner,
        Warehouse warehouse,
        Item item,
        ItemLot lot,
        StockStatus stockStatus
    ) {
        return inventoryStockJpaRepository.findAllForUpdateWithoutLocation(owner, warehouse, item, lot, stockStatus);
    }
}
