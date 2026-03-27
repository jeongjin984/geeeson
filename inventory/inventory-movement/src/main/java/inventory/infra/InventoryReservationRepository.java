package inventory.infra;

import inventory.domain.entity.InventoryReservation;
import inventory.infra.jpa.InventoryReservationJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventoryReservationRepository {
    private final InventoryReservationJpaRepository inventoryReservationJpaRepository;
}
