package inventory.infra.jpa;

import inventory.domain.entity.Item;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryJpaRepository extends JpaRepository<Item, Long> {
}
