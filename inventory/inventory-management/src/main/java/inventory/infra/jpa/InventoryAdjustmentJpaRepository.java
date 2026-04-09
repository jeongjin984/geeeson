package inventory.infra.jpa;

import inventory.domain.adjustment.entity.InventoryAdjustment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryAdjustmentJpaRepository extends JpaRepository<InventoryAdjustment, Long> {
}
