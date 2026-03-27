package inventory.infra;

import inventory.domain.entity.InventoryAdjustmentLine;
import inventory.infra.jpa.InventoryAdjustmentLineJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventoryAdjustmentLineRepository {
    private final InventoryAdjustmentLineJpaRepository inventoryAdjustmentLineJpaRepository;
}
