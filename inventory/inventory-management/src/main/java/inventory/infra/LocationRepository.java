package inventory.infra;

import inventory.domain.master.entity.Location;
import inventory.infra.jpa.LocationJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class LocationRepository {
    private final LocationJpaRepository locationJpaRepository;

    public Location save(Location location) {
        return locationJpaRepository.save(location);
    }

    public Optional<Location> findById(Long id) {
        return locationJpaRepository.findById(id);
    }
}
