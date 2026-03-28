package inventory.infra;

import inventory.domain.entity.InventoryAdjustment;
import inventory.infra.jpa.InventoryAdjustmentJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class InventoryAdjustmentRepository {
    private final InventoryAdjustmentJpaRepository inventoryAdjustmentJpaRepository;

    public Optional<InventoryAdjustment> findById(Long id) {
        return inventoryAdjustmentJpaRepository.findById(id);
    }
}
