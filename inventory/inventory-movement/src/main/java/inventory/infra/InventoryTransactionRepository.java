package inventory.infra;

import inventory.domain.entity.InventoryTransaction;
import inventory.infra.jpa.InventoryTransactionJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventoryTransactionRepository {
    private final InventoryTransactionJpaRepository inventoryTransactionJpaRepository;
}
