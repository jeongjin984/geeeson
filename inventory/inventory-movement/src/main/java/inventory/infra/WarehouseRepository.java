package inventory.infra;

import inventory.domain.entity.Warehouse;
import inventory.infra.jpa.WarehouseJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class WarehouseRepository {
    private final WarehouseJpaRepository warehouseJpaRepository;

    public Warehouse save(Warehouse warehouse) {
        return warehouseJpaRepository.save(warehouse);
    }

    public Optional<Warehouse> findById(Long id) {
        return warehouseJpaRepository.findById(id);
    }

    public List<Warehouse> findAll() {
        return warehouseJpaRepository.findAll();
    }
}
