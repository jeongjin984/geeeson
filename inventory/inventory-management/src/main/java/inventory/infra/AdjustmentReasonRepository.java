package inventory.infra;

import inventory.infra.jpa.AdjustmentReasonJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AdjustmentReasonRepository {
    private final AdjustmentReasonJpaRepository adjustmentReasonJpaRepository;
}
