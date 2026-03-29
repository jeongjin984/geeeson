package inventory.infra;

import inventory.domain.entity.Item;
import inventory.infra.jpa.ItemJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class ItemRepository {
    private final ItemJpaRepository itemJpaRepository;

    public Item save(Item item) {
        return itemJpaRepository.save(item);
    }

    public Optional<Item> findById(Long id) {
        return itemJpaRepository.findById(id);
    }

    public Optional<Item> findByItemCode(String itemCode) {
        return itemJpaRepository.findByItemCode(itemCode);
    }

    public List<Item> findAll() {
        return itemJpaRepository.findAll();
    }
}
