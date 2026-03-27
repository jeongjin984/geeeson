package inventory.infra;

import inventory.domain.entity.ItemLot;
import inventory.infra.jpa.ItemLotJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ItemLotRepository {
    private final ItemLotJpaRepository itemLotJpaRepository;
}
