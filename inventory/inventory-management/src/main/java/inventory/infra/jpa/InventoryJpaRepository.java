package inventory.infra.jpa;

import inventory.domain.stock.entity.InventoryStock;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryJpaRepository extends JpaRepository<InventoryStock, Long> {
}
