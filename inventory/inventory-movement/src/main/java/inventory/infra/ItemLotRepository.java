package inventory.infra;

import inventory.domain.entity.ItemLot;
import inventory.infra.jpa.ItemLotJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class ItemLotRepository {
    private final ItemLotJpaRepository itemLotJpaRepository;

    public Optional<ItemLot> findById(Long id) {
        return itemLotJpaRepository.findById(id);
    }
}
