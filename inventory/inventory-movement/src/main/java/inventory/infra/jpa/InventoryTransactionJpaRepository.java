package inventory.infra.jpa;

import inventory.domain.entity.InventoryOwner;
import inventory.domain.entity.InventoryTransaction;
import inventory.domain.entity.Item;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InventoryTransactionJpaRepository extends JpaRepository<InventoryTransaction, Long> {
    List<InventoryTransaction> findByOwnerAndItem(InventoryOwner owner, Item item);
}
