package inventory.infra;

import inventory.domain.entity.Warehouse;
import inventory.infra.jpa.WarehouseJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class WarehouseRepository {
    private final WarehouseJpaRepository warehouseJpaRepository;
}
