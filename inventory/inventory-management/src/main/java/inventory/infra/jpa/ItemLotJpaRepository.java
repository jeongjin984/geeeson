package inventory.infra.jpa;

import inventory.domain.master.entity.ItemLot;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ItemLotJpaRepository extends JpaRepository<ItemLot, Long> {
}
