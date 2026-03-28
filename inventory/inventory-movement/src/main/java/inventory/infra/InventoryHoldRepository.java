package inventory.infra;

import inventory.domain.entity.InventoryHold;
import inventory.infra.jpa.InventoryHoldJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class InventoryHoldRepository {
    private final InventoryHoldJpaRepository inventoryHoldJpaRepository;

    public InventoryHold save(InventoryHold hold) {
        return inventoryHoldJpaRepository.save(hold);
    }

    public Optional<InventoryHold> findById(Long id) {
        return inventoryHoldJpaRepository.findById(id);
    }
}
