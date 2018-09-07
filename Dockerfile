FROM alpine:edge

EXPOSE 80
CMD ["/dispatcher"]

COPY dispatcher /
COPY static /static/
