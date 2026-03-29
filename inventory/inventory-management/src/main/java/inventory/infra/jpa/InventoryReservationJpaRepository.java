package inventory.infra.jpa;

import inventory.domain.entity.InventoryReservation;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryReservationJpaRepository extends JpaRepository<InventoryReservation, Long> {
}
