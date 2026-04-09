package inventory.infra;

import inventory.domain.inbound.entity.InboundReceipt;
import inventory.infra.jpa.InboundReceiptJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class InboundReceiptRepository {
    private final InboundReceiptJpaRepository inboundReceiptJpaRepository;

    public Optional<InboundReceipt> findById(Long id) {
        return inboundReceiptJpaRepository.findById(id);
    }
}
