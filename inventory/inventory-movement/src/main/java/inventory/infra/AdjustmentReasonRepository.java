package inventory.infra;

import inventory.domain.entity.AdjustmentReason;
import inventory.infra.jpa.AdjustmentReasonJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AdjustmentReasonRepository {
    private final AdjustmentReasonJpaRepository adjustmentReasonJpaRepository;
}
