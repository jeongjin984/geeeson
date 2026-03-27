package inventory.infra.jpa;

import inventory.domain.entity.Zone;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ZoneJpaRepository extends JpaRepository<Zone, Long> {
}
