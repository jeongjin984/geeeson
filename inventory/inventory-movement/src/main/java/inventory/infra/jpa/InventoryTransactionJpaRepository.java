package inventory.infra.jpa;

import inventory.domain.entity.InventoryTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryTransactionJpaRepository extends JpaRepository<InventoryTransaction, Long> {
}
