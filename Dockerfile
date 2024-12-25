# Dockerfile
FROM public.ecr.aws/lambda/python:3.9

# Copy application code
COPY lambda_function.py ./

# Install dependencies
RUN pip install requests

# Set the handler
CMD ["lambda_function.lambda_handler"]