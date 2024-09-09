# Use the official Python image from the Docker Hub
FROM python:3.6-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y \
       build-essential \
       default-libmysqlclient-dev \
       libffi-dev \
       libssl-dev \
       curl \
       gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Copy the requirements file and install Python dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

# Copy the application code to the container
COPY . /app/
COPY .env /app/
# Set environment variables for Django
#ENV DJANGO_SETTINGS_MODULE=myproject.settings

# Install Node.js dependencies
WORKDIR /app/bundles
RUN npm install

# Set the working directory back
WORKDIR /app

# Expose the port for the Django application
EXPOSE 8000

# Run Django migrations and start the server
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]

