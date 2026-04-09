package inventory.infra.jpa;

import inventory.domain.master.entity.Location;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LocationJpaRepository extends JpaRepository<Location, Long> {
}
