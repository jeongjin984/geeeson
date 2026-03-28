package inventory.infra;

import inventory.domain.entity.InventoryOwner;
import inventory.domain.entity.InventoryTransaction;
import inventory.domain.entity.Item;
import inventory.infra.jpa.InventoryTransactionJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class InventoryTransactionRepository {
    private final InventoryTransactionJpaRepository inventoryTransactionJpaRepository;

    public InventoryTransaction save(InventoryTransaction transaction) {
        return inventoryTransactionJpaRepository.save(transaction);
    }

    public List<InventoryTransaction> findByOwnerAndItem(InventoryOwner owner, Item item) {
        return inventoryTransactionJpaRepository.findByOwnerAndItem(owner, item);
    }
}
