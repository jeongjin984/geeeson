package inventory.infra.jpa;

import inventory.domain.entity.InventoryStock;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryJpaRepository extends JpaRepository<InventoryStock, Long> {
}
