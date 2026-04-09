package inventory.infra;

import inventory.domain.adjustment.entity.InventoryAdjustment;
import inventory.domain.adjustment.entity.InventoryAdjustmentLine;
import inventory.infra.jpa.InventoryAdjustmentLineJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class InventoryAdjustmentLineRepository {
    private final InventoryAdjustmentLineJpaRepository inventoryAdjustmentLineJpaRepository;

    public List<InventoryAdjustmentLine> findByInventoryAdjustment(InventoryAdjustment inventoryAdjustment) {
        return inventoryAdjustmentLineJpaRepository.findByInventoryAdjustment(inventoryAdjustment);
    }
}
