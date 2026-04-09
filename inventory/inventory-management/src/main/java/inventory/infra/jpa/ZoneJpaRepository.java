package inventory.infra.jpa;

import inventory.domain.master.entity.Zone;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ZoneJpaRepository extends JpaRepository<Zone, Long> {
}
