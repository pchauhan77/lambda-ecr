# Use the official AWS Lambda Python base image
FROM public.ecr.aws/lambda/python:3.9

# Set the working directory in the container
WORKDIR ${LAMBDA_TASK_ROOT}

# Copy the application code into the container
COPY src/lambda_function.py ${LAMBDA_TASK_ROOT}/

# Install dependencies
RUN pip install requests --target "${LAMBDA_TASK_ROOT}"

# Set the CMD to the Lambda handler
CMD ["lambda_function.lambda_handler"]