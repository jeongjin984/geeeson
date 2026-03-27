package inventory.infra.jpa;

import inventory.domain.entity.InventoryOwner;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryOwnerJpaRepository extends JpaRepository<InventoryOwner, Long> {
}
