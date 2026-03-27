package inventory.infra;

import inventory.domain.entity.InventoryOwner;
import inventory.infra.jpa.InventoryOwnerJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InventoryOwnerRepository {
    private final InventoryOwnerJpaRepository inventoryOwnerJpaRepository;
}
