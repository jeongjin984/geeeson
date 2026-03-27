package inventory.infra.jpa;

import inventory.domain.entity.InboundReceipt;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InboundReceiptJpaRepository extends JpaRepository<InboundReceipt, Long> {
}
