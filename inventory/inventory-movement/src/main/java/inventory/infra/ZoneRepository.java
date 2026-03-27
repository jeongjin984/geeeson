package inventory.infra;

import inventory.domain.entity.Zone;
import inventory.infra.jpa.ZoneJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ZoneRepository {
    private final ZoneJpaRepository zoneJpaRepository;
}
