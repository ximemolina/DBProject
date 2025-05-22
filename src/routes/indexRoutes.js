import { Router } from 'express';
import generalRoutes from './generalRoutes.js';
import loginRoutes from './loginRoutes.js';

const rutas_init = () => {
  const router = Router()

  router.use('/', generalRoutes);
  router.use('/login', loginRoutes);
  router.use('/general', generalRoutes);

  return router
}

export default rutas_init;