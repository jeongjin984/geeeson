package inventory.infra;

import inventory.infra.jpa.InventoryJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventoryRepository {
    private final InventoryJpaRepository inventoryJpaRepository;
}
