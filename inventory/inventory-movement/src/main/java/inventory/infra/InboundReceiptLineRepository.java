package inventory.infra;

import inventory.domain.entity.InboundReceiptLine;
import inventory.infra.jpa.InboundReceiptLineJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class InboundReceiptLineRepository {
    private final InboundReceiptLineJpaRepository inboundReceiptLineJpaRepository;
}
