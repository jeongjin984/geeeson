package inventory.infra.jpa;

import inventory.domain.entity.Item;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ItemJpaRepository extends JpaRepository<Item, Long> {
    Optional<Item> findByItemCode(String itemCode);
}
