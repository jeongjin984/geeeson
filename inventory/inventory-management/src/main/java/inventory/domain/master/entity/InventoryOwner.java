package inventory.domain.master.entity;

import inventory.common.entity.BaseTimeEntity;
import inventory.common.enums.OwnerType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "inventory_owner",
       uniqueConstraints = @UniqueConstraint(name = "uq_inventory_owner_code", columnNames = "owner_code"))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class InventoryOwner extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "owner_id")
    private Long id;

    @Column(name = "owner_code", nullable = false, length = 30)
    private String ownerCode;

    @Column(name = "owner_name", nullable = false, length = 200)
    private String ownerName;

    @Enumerated(EnumType.STRING)
    @Column(name = "owner_type", nullable = false, length = 20)
    private OwnerType ownerType;

    @Column(name = "is_active", nullable = false)
    private Boolean active;
}