FROM ghcr.io/gleam-lang/gleam:v1.5.1-erlang-alpine

# Add LiteFS binary, to replicate the SQLite database.
# COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /usr/local/bin/litefs

# Add project code
COPY . /build/

# Compile the Gleam application
RUN cd /build \
  && apk add bash curl fuse3 ca-certificates sqlite gcc build-base \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && rm -r /build \
  && apk del gcc build-base \
  && addgroup -S webuser \
  && adduser -S webuser -G webuser \
  && chown -R webuser /app

# COPY litefs.yml /etc/litefs.yml

# EXPOSE 8080

# Run the application
USER webuser
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]

# ENTRYPOINT ["litefs", "mount"]