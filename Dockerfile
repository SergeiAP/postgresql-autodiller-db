FROM postgres:14
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=autodiller_salon
ADD ./db/ddl/* /docker-entrypoint-initdb.d/
ADD ./dml/* /root/sql_dmls/