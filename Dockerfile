FROM alpine:edge

COPY wordsmith-front /
COPY static /static/

EXPOSE 80
CMD ["/wordsmith-front"]