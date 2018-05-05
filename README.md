# Quiz Creation

## Development

### Database

#### Creation

Get the latest 9.4 version of postgres and start it

```
  docker run -e POSTGRES_USER=zaid -e POSTGRES_PASSWORD=iwantmsn -p 5432:5432 -d postgres:9.4
```

####  Setup and Migration

Run the setup & migration script

```
  rake db:setup
  rake db:migrate
```

### Start Server

Start the server on port 5000

```
  rails s -p 5000
```

## Docker

### Create Secret

```
  rake secret
```


### Start Server

```
  docker run -e SECRET_KEY_BASE=<secret-base> \
    -e DATABASE_URL="<postgres://username:password@domain:port/database>" \
    -e APP_DOMAIN="quiz-creation.cogliapp.com" \
    -e MAILER_DOMAIN="quiz-creation.cogliapp.com" \
    -e PARENT_PORTAL_URL="portal.cogliapp.com" \
    -e RACK_ENV=production \
    -e RAILS_ENV=production \
    -e SMTP_LOGIN="customerservice.staging@cogliapp.com" \
    -e SMTP_PASSWORD=<smtp-password> \
    -e SMTP_SERVER=smtp.mailgun.org \
    -e SMTP_PORT=25 \
    -p 3000:3000 \
    -d cogli-parent-portal:latest
```


# Copyright

Cogli, LLC
