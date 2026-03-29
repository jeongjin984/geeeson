package inventory.infra;

import inventory.domain.entity.Zone;
import inventory.infra.jpa.ZoneJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class ZoneRepository {
    private final ZoneJpaRepository zoneJpaRepository;

    public Zone save(Zone zone) {
        return zoneJpaRepository.save(zone);
    }

    public Optional<Zone> findById(Long id) {
        return zoneJpaRepository.findById(id);
    }
}
