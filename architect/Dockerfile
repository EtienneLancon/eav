FROM alpine:latest

RUN apk update && apk add py3-pip && pip install uvicorn && pip install psycopg2-binary

WORKDIR /code

EXPOSE 8001:8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0"]