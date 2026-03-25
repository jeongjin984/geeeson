package geeson.order;

import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class OrderJobConfig {

    @Bean
    public Job orderConfig(
        JobRepository jobRepository
    ) {
        return new JobBuilder("createOrderJob", jobRepository)
            .build();
    }
}
