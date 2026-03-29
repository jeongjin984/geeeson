package inventory.infra;

import inventory.domain.entity.InventorySnapshot;
import inventory.infra.jpa.InventorySnapshotJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventorySnapshotRepository {
    private final InventorySnapshotJpaRepository inventorySnapshotJpaRepository;

    public InventorySnapshot save(InventorySnapshot inventorySnapshot) {
        return inventorySnapshotJpaRepository.save(inventorySnapshot);
    }
}
