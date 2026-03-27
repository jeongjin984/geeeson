package inventory.infra;

import inventory.domain.entity.Item;
import inventory.infra.jpa.InventoryJpaRepository;
import inventory.infra.jpa.ItemJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventoryRepository {
    private final InventoryJpaRepository inventoryJpaRepository;
}
