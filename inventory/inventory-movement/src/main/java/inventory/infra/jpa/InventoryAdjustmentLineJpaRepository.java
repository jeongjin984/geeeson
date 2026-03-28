package inventory.infra.jpa;

import inventory.domain.entity.InventoryAdjustment;
import inventory.domain.entity.InventoryAdjustmentLine;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InventoryAdjustmentLineJpaRepository extends JpaRepository<InventoryAdjustmentLine, Long> {
    List<InventoryAdjustmentLine> findByInventoryAdjustment(InventoryAdjustment inventoryAdjustment);
}
