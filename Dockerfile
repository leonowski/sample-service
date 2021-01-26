FROM python:3.8 as build

COPY . .
ENV FLASK_APP=app/app.py
RUN pip3 install --upgrade pip
RUN pip install -r requirements.txt


FROM python:3.8-slim
COPY --from=build /app /app
COPY --from=build /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
ENV FLASK_APP=app/app.py

EXPOSE 5000

CMD python -m flask run --host 0.0.0.0
