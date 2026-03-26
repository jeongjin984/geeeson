package geeson.inventory;

import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class InventoryJobConfig {
    @Bean
    public Job jobConfig(JobRepository jobRepository) {
        return new JobBuilder("inventorySimulationJob", jobRepository)
            .start()
            .build();
    }

    @Bean
    public
}
