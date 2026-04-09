package inventory.infra;

import inventory.domain.inbound.entity.InboundReceipt;
import inventory.domain.inbound.entity.InboundReceiptLine;
import inventory.infra.jpa.InboundReceiptLineJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class InboundReceiptLineRepository {
    private final InboundReceiptLineJpaRepository inboundReceiptLineJpaRepository;

    public List<InboundReceiptLine> findByInboundReceipt(InboundReceipt inboundReceipt) {
        return inboundReceiptLineJpaRepository.findByInboundReceipt(inboundReceipt);
    }
}
