SEAPAY_VERSION=0.0.1
TEST_DB_NAME="sea_pay_dev_test"
TEST_DB_PORT=5432

all: clean testdb-setup build test

db-setup: db-create db-migrate

db-drop:
	dropdb -h ${DB_HOST} -p ${DB_PORT} --if-exists -Upostgres ${DB_NAME}

db-create:
	createdb -h ${DB_HOST} -p ${DB_PORT} -Opostgres -Eutf8 ${DB_NAME}

db-migrate:
	./gradlew migrateDb

testdb-setup: testdb-create testdb-migrate

testdb-create: testdb-drop
	createdb -p $(TEST_DB_PORT) -U postgres -Eutf8 $(TEST_DB_NAME)

testdb-migrate:
	./gradlew migrateTestDb

testdb-drop:
	dropdb -p $(TEST_DB_PORT) --if-exists -U postgres $(TEST_DB_NAME)

cidb-migrate:
	APP_ENVIRONMENT=test ./gradlew migrateCiDb

.PHONY: test
test:
	./gradlew test check jacocoTestReport coverageReport

test-ci: clean cidb-migrate ci-build
	APP_ENVIRONMENT=test ./gradlew test check jacocoTestReport coverageReport

build:
	./gradlew build

ci-build:
	APP_ENVIRONMENT=test ./gradlew build

clean:
	./gradlew clean
