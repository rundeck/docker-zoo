Oracle XE Exhibit
==============

# How to Use

## Download Oracle JDBC Driver

[Download the Oracle JDBC driver "ojdbc8.jar"](https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html) and place in `lib/` .

```
VERS=21.5.0.0
curl https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/$VERS/ojdbc8-$VERS.jar -o lib/ojdbc8-$VERS.jar
```

## Start

```
docker-compose up -d
```

## Stop

```
docker-compose down -v
```
