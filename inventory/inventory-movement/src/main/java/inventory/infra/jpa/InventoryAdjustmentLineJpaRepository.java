package inventory.infra.jpa;

import inventory.domain.entity.InventoryAdjustmentLine;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryAdjustmentLineJpaRepository extends JpaRepository<InventoryAdjustmentLine, Long> {
}
