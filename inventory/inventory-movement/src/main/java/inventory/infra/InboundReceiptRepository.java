package inventory.infra;

import inventory.domain.entity.InboundReceipt;
import inventory.infra.jpa.InboundReceiptJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InboundReceiptRepository {
    private final InboundReceiptJpaRepository inboundReceiptJpaRepository;
}
