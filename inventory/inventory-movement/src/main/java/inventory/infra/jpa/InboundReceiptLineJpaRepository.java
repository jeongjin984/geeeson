package inventory.infra.jpa;

import inventory.domain.entity.InboundReceiptLine;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InboundReceiptLineJpaRepository extends JpaRepository<InboundReceiptLine, Long> {
}
