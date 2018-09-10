FROM alpine:edge

COPY dispatcher /
COPY static /static/

EXPOSE 80
CMD ["/dispatcher"]