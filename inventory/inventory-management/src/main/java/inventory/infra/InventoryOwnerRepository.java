package inventory.infra;

import inventory.domain.master.entity.InventoryOwner;
import inventory.infra.jpa.InventoryOwnerJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class InventoryOwnerRepository {
    private final InventoryOwnerJpaRepository inventoryOwnerJpaRepository;

    public InventoryOwner save(InventoryOwner owner) {
        return inventoryOwnerJpaRepository.save(owner);
    }

    public Optional<InventoryOwner> findById(Long id) {
        return inventoryOwnerJpaRepository.findById(id);
    }
}
