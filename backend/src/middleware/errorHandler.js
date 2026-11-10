/**
 * Global error handler middleware.
 * Catches all errors thrown in route handlers and formats them consistently.
 */
const errorHandler = (err, req, res, _next) => {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';

  // Prisma unique constraint violation (for example, duplicate email).
  if (err.code === 'P2002') {
    const target = err.meta?.target;
    const field = Array.isArray(target) ? target[0] : target || 'value';
    statusCode = 400;
    message = `${field.charAt(0).toUpperCase() + field.slice(1)} already exists`;
  }

  // Invalid Prisma input should be reported as a client error.
  if (err.name === 'PrismaClientValidationError') {
    statusCode = 400;
    message = 'Invalid request data';
  }

  // Invalid or missing records and invalid database identifiers.
  if (err.code === 'P2025') {
    statusCode = 404;
    message = 'Requested record was not found';
  } else if (err.code === 'P2003') {
    statusCode = 400;
    message = 'The request references a record that does not exist';
  } else if (err.code === 'P2023') {
    statusCode = 400;
    message = 'Invalid record identifier';
  }

  if (process.env.NODE_ENV === 'development') {
    console.error('[ERROR]', err.stack || err);
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = errorHandler;
