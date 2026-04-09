package inventory.infra.jpa;

import inventory.domain.stock.entity.InventorySnapshot;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventorySnapshotJpaRepository extends JpaRepository<InventorySnapshot, Long> {
}
