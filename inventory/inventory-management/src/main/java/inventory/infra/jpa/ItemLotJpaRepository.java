package inventory.infra.jpa;

import inventory.domain.entity.ItemLot;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ItemLotJpaRepository extends JpaRepository<ItemLot, Long> {
}
