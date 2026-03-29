package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.ReasonType;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "adjustment_reason",
       uniqueConstraints = @UniqueConstraint(name = "uq_adjustment_reason_code", columnNames = "reason_code"))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AdjustmentReason extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "adjustment_reason_id")
    private Long id;

    @Column(name = "reason_code", nullable = false, length = 30)
    private String reasonCode;

    @Column(name = "reason_name", nullable = false, length = 100)
    private String reasonName;

    @Enumerated(EnumType.STRING)
    @Column(name = "reason_type", nullable = false, length = 20)
    private ReasonType reasonType;

    @Column(name = "is_active", nullable = false)
    private Boolean active;
}