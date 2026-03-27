package inventory.infra;

import inventory.domain.entity.InventoryAdjustment;
import inventory.infra.jpa.InventoryAdjustmentJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventoryAdjustmentRepository {
    private final InventoryAdjustmentJpaRepository inventoryAdjustmentJpaRepository;
}
