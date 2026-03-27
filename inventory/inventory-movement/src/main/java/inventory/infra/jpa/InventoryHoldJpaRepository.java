package inventory.infra.jpa;

import inventory.domain.entity.InventoryHold;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryHoldJpaRepository extends JpaRepository<InventoryHold, Long> {
}
