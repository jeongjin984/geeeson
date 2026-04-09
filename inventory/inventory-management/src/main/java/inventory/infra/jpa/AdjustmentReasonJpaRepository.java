package inventory.infra.jpa;

import inventory.domain.master.entity.AdjustmentReason;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdjustmentReasonJpaRepository extends JpaRepository<AdjustmentReason, Long> {
}
