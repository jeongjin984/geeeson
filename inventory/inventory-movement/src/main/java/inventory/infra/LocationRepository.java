package inventory.infra;

import inventory.domain.entity.Location;
import inventory.infra.jpa.LocationJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LocationRepository {
    private final LocationJpaRepository locationJpaRepository;
}
