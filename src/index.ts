import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { logger } from 'hono/logger';

const app = new Hono();

app.use('*', logger());

app.get('/', (c) => {
  return c.text('Hello Hono!');
});

const port = 3100;
// console.log(`Server is running on port ${port}`); 0301 148102

serve({
  fetch: app.fetch,
  port,
});
