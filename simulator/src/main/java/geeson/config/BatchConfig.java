package geeson.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.repository.support.JobRepositoryFactoryBean;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.support.JdbcTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionManager;

import javax.sql.DataSource;

@Configuration
@EnableBatchProcessing(
    dataSourceRef = "batchDataSource",
    transactionManagerRef = "batchTransactionManager",
    tablePrefix = "BATCH_",
    maxVarCharLength = 1000,
    isolationLevelForCreate = "REPEATABLE_READ"
)
public class BatchConfig {
    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.hikari")
    public HikariConfig hikariConfig() {
        return new HikariConfig();
    }

    @Bean
    public DataSource batchDataSource() {
        return new HikariDataSource(hikariConfig());
    }

    @Bean
    public PlatformTransactionManager batchTransactionManager() {
        return new JdbcTransactionManager(batchDataSource());
    }

    @Bean
    public JobRepository jobRepository(
        @Qualifier("batchDataSource") DataSource dataSource,
        @Qualifier("batchTransactionManager") PlatformTransactionManager transactionManager
    ) throws Exception {
        JobRepositoryFactoryBean factory = new JobRepositoryFactoryBean();
        factory.setDataSource(dataSource);
        factory.setDatabaseType("mysql");
        factory.setTransactionManager(transactionManager);

        return factory.getObject();
    }
}
