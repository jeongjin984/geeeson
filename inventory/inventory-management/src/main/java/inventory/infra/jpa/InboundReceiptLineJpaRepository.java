package inventory.infra.jpa;

import inventory.domain.entity.InboundReceipt;
import inventory.domain.entity.InboundReceiptLine;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InboundReceiptLineJpaRepository extends JpaRepository<InboundReceiptLine, Long> {
    List<InboundReceiptLine> findByInboundReceipt(InboundReceipt inboundReceipt);
}
