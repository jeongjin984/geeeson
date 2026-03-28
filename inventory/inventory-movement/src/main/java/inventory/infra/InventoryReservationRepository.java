package inventory.infra;

import inventory.domain.entity.InventoryReservation;
import inventory.infra.jpa.InventoryReservationJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class InventoryReservationRepository {
    private final InventoryReservationJpaRepository inventoryReservationJpaRepository;

    public InventoryReservation save(InventoryReservation reservation) {
        return inventoryReservationJpaRepository.save(reservation);
    }

    public Optional<InventoryReservation> findById(Long id) {
        return inventoryReservationJpaRepository.findById(id);
    }
}
