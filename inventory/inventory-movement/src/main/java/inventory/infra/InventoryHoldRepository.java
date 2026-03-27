package inventory.infra;

import inventory.domain.entity.InventoryHold;
import inventory.infra.jpa.InventoryHoldJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventoryHoldRepository {
    private final InventoryHoldJpaRepository inventoryHoldJpaRepository;
}
