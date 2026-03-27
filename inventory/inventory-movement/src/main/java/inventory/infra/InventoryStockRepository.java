package inventory.infra;

import inventory.domain.entity.InventoryStock;
import inventory.infra.jpa.InventoryStockJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventoryStockRepository {
    private final InventoryStockJpaRepository inventoryStockJpaRepository;
}
